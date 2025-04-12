#include "AppController.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrlQuery>
#include <QSettings>

AppController::AppController(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_positionSource(QGeoPositionInfoSource::createDefaultSource(this))
    , m_restaurantModel(new RestaurantModel(this))
    , m_loading(false)
    , m_error("")
    , m_locationPermissionGranted(false)
    , m_userLatitude(0.0)
    , m_userLongitude(0.0)
    , m_baseUrl("http://localhost:8000/api")
    , m_authToken("")
    , m_isAuthenticated(false)
{
    connect(m_networkManager, &QNetworkAccessManager::finished, this, &AppController::handleNetworkReply);

    if (m_positionSource) {
        connect(m_positionSource, &QGeoPositionInfoSource::positionUpdated, this, &AppController::onPositionUpdated);
        connect(m_positionSource, &QGeoPositionInfoSource::errorOccurred, this, &AppController::onPositionError);
    }

    // Restore settings
    QSettings settings;
    m_locationPermissionGranted = settings.value("locationPermission", false).toBool();
    m_authToken = settings.value("authToken", "").toString();
    m_isAuthenticated = !m_authToken.isEmpty();
}

AppController::~AppController()
{
}

bool AppController::loading() const
{
    return m_loading;
}

QString AppController::error() const
{
    return m_error;
}

RestaurantModel* AppController::restaurantModel()
{
    return m_restaurantModel;
}

bool AppController::locationPermissionGranted() const
{
    return m_locationPermissionGranted;
}

void AppController::setLocationPermissionGranted(bool granted)
{
    if (m_locationPermissionGranted != granted) {
        m_locationPermissionGranted = granted;
        QSettings settings;
        settings.setValue("locationPermission", granted);

        if (granted && m_positionSource) {
            m_positionSource->startUpdates();
        } else if (m_positionSource) {
            m_positionSource->stopUpdates();
        }

        emit locationPermissionGrantedChanged();
    }
}

double AppController::userLatitude() const
{
    return m_userLatitude;
}

double AppController::userLongitude() const
{
    return m_userLongitude;
}

QString AppController::authToken() const
{
    return m_authToken;
}

bool AppController::isAuthenticated() const
{
    return m_isAuthenticated;
}

void AppController::initialize()
{
    if (m_locationPermissionGranted && m_positionSource) {
        m_positionSource->startUpdates();
    }
}

void AppController::searchRestaurants(const QString &query, int radius, const QString &cuisineType, int rating)
{
    if (m_userLatitude == 0.0 && m_userLongitude == 0.0) {
        setError("Location not available. Please enable location services.");
        return;
    }

    setLoading(true);

    QUrl url(m_baseUrl + "/restaurants/search");
    QUrlQuery urlQuery;
    urlQuery.addQueryItem("latitude", QString::number(m_userLatitude));
    urlQuery.addQueryItem("longitude", QString::number(m_userLongitude));
    urlQuery.addQueryItem("radius", QString::number(radius));

    if (!query.isEmpty()) {
        urlQuery.addQueryItem("query", query);
    }

    if (!cuisineType.isEmpty()) {
        urlQuery.addQueryItem("cuisine", cuisineType);
    }

    if (rating > 0) {
        urlQuery.addQueryItem("min_rating", QString::number(rating));
    }

    url.setQuery(urlQuery);

    QNetworkRequest request = createRequest(url);

    m_networkManager->get(request);
}

void AppController::refreshRestaurants()
{
    fetchNearbyRestaurants();
}

void AppController::clearError()
{
    setError("");
}

void AppController::requestLocationPermission()
{
    setLocationPermissionGranted(true);
}

QNetworkRequest AppController::createRequest(const QUrl &url)
{
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    if (!m_authToken.isEmpty()) {
        request.setRawHeader("Authorization", QString("Bearer %1").arg(m_authToken).toUtf8());
    }
    return request;
}

void AppController::login(const QString &username, const QString &password)
{
    setLoading(true);

    QUrl url(m_baseUrl + "/auth/login");
    QNetworkRequest request = createRequest(url);

    QJsonObject json;
    json["username"] = username;
    json["password"] = password;

    QNetworkReply *reply = m_networkManager->post(request, QJsonDocument(json).toJson());
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        handleAuthResponse(QJsonDocument::fromJson(reply->readAll()));
        reply->deleteLater();
    });
}

void AppController::logout()
{
    setAuthToken("");
    setAuthenticated(false);
    QSettings settings;
    settings.remove("authToken");
}

void AppController::registerUser(const QString &username, const QString &password, const QString &email)
{
    setLoading(true);

    QUrl url(m_baseUrl + "/auth/register");
    QNetworkRequest request = createRequest(url);

    QJsonObject json;
    json["username"] = username;
    json["password"] = password;
    json["email"] = email;

    QNetworkReply *reply = m_networkManager->post(request, QJsonDocument(json).toJson());
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        handleAuthResponse(QJsonDocument::fromJson(reply->readAll()));
        reply->deleteLater();
    });
}

void AppController::handleAuthResponse(const QJsonDocument &doc)
{
    setLoading(false);

    if (doc.isNull()) {
        emit loginFailed("Invalid response from server");
        return;
    }

    QJsonObject obj = doc.object();
    if (obj.contains("error")) {
        emit loginFailed(obj["error"].toString());
        return;
    }

    if (obj.contains("token")) {
        setAuthToken(obj["token"].toString());
        setAuthenticated(true);
        QSettings settings;
        settings.setValue("authToken", m_authToken);
        emit loginSuccessful();
    }
}

void AppController::handleRestaurantResponse(const QJsonDocument &doc)
{
    if (doc.isNull()) {
        setError("Invalid response from server");
        return;
    }

    if (doc.isArray()) {
        m_restaurantModel->updateFromJson(doc.array());
    } else if (doc.isObject() && doc.object().contains("results")) {
        m_restaurantModel->updateFromJson(doc.object()["results"].toArray());
    }
}

void AppController::handleNetworkReply(QNetworkReply *reply)
{
    setLoading(false);

    if (reply->error() != QNetworkReply::NoError) {
        if (reply->error() == QNetworkReply::AuthenticationRequiredError) {
            setAuthenticated(false);
            setAuthToken("");
            QSettings settings;
            settings.remove("authToken");
            emit loginFailed("Session expired. Please login again.");
        } else {
            setError("Network error: " + reply->errorString());
        }
        reply->deleteLater();
        return;
    }

    QByteArray data = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);

    if (reply->url().toString().contains("/auth")) {
        handleAuthResponse(doc);
    } else if (reply->url().toString().contains("/restaurants")) {
        handleRestaurantResponse(doc);
    }

    reply->deleteLater();
}

void AppController::setAuthToken(const QString &token)
{
    if (m_authToken != token) {
        m_authToken = token;
        emit authTokenChanged();
    }
}

void AppController::setAuthenticated(bool authenticated)
{
    if (m_isAuthenticated != authenticated) {
        m_isAuthenticated = authenticated;
        emit isAuthenticatedChanged();
    }
}

void AppController::onPositionUpdated(const QGeoPositionInfo &info)
{
    QGeoCoordinate coord = info.coordinate();
    updateUserLocation(coord.latitude(), coord.longitude());

    // Initial fetch once we have location
    if (m_restaurantModel->rowCount() == 0) {
        fetchNearbyRestaurants();
    }
}

void AppController::onPositionError(QGeoPositionInfoSource::Error error)
{
    QString errorMsg;

    switch (error) {
    case QGeoPositionInfoSource::AccessError:
        errorMsg = "Location access denied. Please check your permissions.";
        break;
    case QGeoPositionInfoSource::ClosedError:
        errorMsg = "Location service has been closed.";
        break;
    default:
        errorMsg = "Location service error occurred.";
        break;
    }

    setError(errorMsg);
}

void AppController::setLoading(bool loading)
{
    if (m_loading != loading) {
        m_loading = loading;
        emit loadingChanged();
    }
}

void AppController::setError(const QString &error)
{
    if (m_error != error) {
        m_error = error;
        emit errorChanged();
    }
}

void AppController::updateUserLocation(double latitude, double longitude)
{
    if (m_userLatitude != latitude || m_userLongitude != longitude) {
        m_userLatitude = latitude;
        m_userLongitude = longitude;
        emit userLocationChanged();
    }
}

void AppController::fetchNearbyRestaurants()
{
    if (m_userLatitude == 0.0 && m_userLongitude == 0.0) {
        return;
    }

    setLoading(true);

    QUrl url(m_baseUrl + "/restaurants/nearby");
    QUrlQuery urlQuery;
    urlQuery.addQueryItem("latitude", QString::number(m_userLatitude));
    urlQuery.addQueryItem("longitude", QString::number(m_userLongitude));
    urlQuery.addQueryItem("radius", "5000");  // Default 5km radius
    url.setQuery(urlQuery);

    QNetworkRequest request = createRequest(url);

    m_networkManager->get(request);
}
