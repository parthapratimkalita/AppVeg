#include "UserController.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QSettings>
#include <QUrlQuery>

UserController::UserController(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_loading(false)
    , m_authUrl("http://localhost:8085/auth")
    , m_apiUrl("http://localhost:8000/api")
{
    connect(m_networkManager, &QNetworkAccessManager::finished, this, &UserController::handleNetworkReply);
    loadStoredCredentials();
}

UserController::~UserController()
{
}

bool UserController::isLoggedIn() const
{
    return !m_authToken.isEmpty();
}

QString UserController::username() const
{
    return m_username;
}

QString UserController::errorMessage() const
{
    return m_errorMessage;
}

bool UserController::loading() const
{
    return m_loading;
}

void UserController::login(const QString &username, const QString &password)
{
    if (username.isEmpty() || password.isEmpty()) {
        setErrorMessage("Username and password cannot be empty");
        return;
    }

    setLoading(true);
    clearError();

    QUrl url(m_authUrl + "/login");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject jsonObject;
    jsonObject["username"] = username;
    jsonObject["password"] = password;

    QJsonDocument doc(jsonObject);

    m_networkManager->post(request, doc.toJson());
}

void UserController::register_(const QString &username, const QString &email, const QString &password)
{
    if (username.isEmpty() || email.isEmpty() || password.isEmpty()) {
        setErrorMessage("All fields are required");
        return;
    }

    setLoading(true);
    clearError();

    QUrl url(m_authUrl + "/register");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QJsonObject jsonObject;
    jsonObject["username"] = username;
    jsonObject["email"] = email;
    jsonObject["password"] = password;

    QJsonDocument doc(jsonObject);

    m_networkManager->post(request, doc.toJson());
}

void UserController::logout()
{
    clearCredentials();
    emit authStateChanged();
}

void UserController::getUserProfile()
{
    if (!isLoggedIn()) {
        return;
    }

    setLoading(true);

    QUrl url(m_authUrl + "/profile");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", QString("Bearer %1").arg(m_authToken).toUtf8());

    m_networkManager->get(request);
}

void UserController::getFavorites()
{
    if (!isLoggedIn()) {
        return;
    }

    setLoading(true);

    QUrl url(m_apiUrl + "/favorites");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", QString("Bearer %1").arg(m_authToken).toUtf8());

    m_networkManager->get(request);
}

void UserController::addToFavorites(const QString &restaurantId)
{
    if (!isLoggedIn() || restaurantId.isEmpty()) {
        return;
    }

    setLoading(true);

    QUrl url(m_apiUrl + "/favorites");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", QString("Bearer %1").arg(m_authToken).toUtf8());

    QJsonObject jsonObject;
    jsonObject["restaurant_id"] = restaurantId;

    QJsonDocument doc(jsonObject);

    m_networkManager->post(request, doc.toJson());
}

void UserController::removeFromFavorites(const QString &restaurantId)
{
    if (!isLoggedIn() || restaurantId.isEmpty()) {
        return;
    }

    setLoading(true);

    QUrl url(m_apiUrl + "/favorites/" + restaurantId);
    QNetworkRequest request(url);
    request.setRawHeader("Authorization", QString("Bearer %1").arg(m_authToken).toUtf8());

    m_networkManager->deleteResource(request);
}

void UserController::clearError()
{
    setErrorMessage("");
}

void UserController::handleNetworkReply(QNetworkReply *reply)
{
    setLoading(false);

    if (reply->error() != QNetworkReply::NoError) {
        // Check if it's a 404 error
        if (reply->error() == QNetworkReply::ContentNotFoundError) {
            // For favorites, treat 404 as empty list
            if (reply->url().path().contains("/favorites")) {
                m_favorites.clear();
                emit favoritesUpdated(m_favorites);
                reply->deleteLater();
                return;
            }
        }
        setErrorMessage("Network error: " + reply->errorString());
        reply->deleteLater();
        return;
    }

    QByteArray data = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);

    if (doc.isNull()) {
        // For favorites, treat empty response as empty list
        if (reply->url().path().contains("/favorites")) {
            m_favorites.clear();
            emit favoritesUpdated(m_favorites);
            reply->deleteLater();
            return;
        }
        setErrorMessage("Invalid response from server");
        reply->deleteLater();
        return;
    }

    QJsonObject jsonObject = doc.object();
    QString urlPath = reply->url().path();

    if (urlPath.contains("/auth/login")) {
        if (jsonObject.contains("access_token")) {
            setUsername(jsonObject["username"].toString());
            setAuthToken(jsonObject["access_token"].toString());
            saveCredentials();
            emit authStateChanged();
        } else if (jsonObject.contains("error")) {
            setErrorMessage(jsonObject["error"].toString());
        }
    } else if (urlPath.contains("/auth/register")) {
        if (jsonObject.contains("id")) {
            setUsername(jsonObject["username"].toString());
            emit userDataChanged();
        } else if (jsonObject.contains("error")) {
            setErrorMessage(jsonObject["error"].toString());
        }
    } else if (urlPath.contains("/auth/profile")) {
        if (jsonObject.contains("username")) {
            setUsername(jsonObject["username"].toString());
            emit userDataChanged();
        }
    } else if (urlPath.contains("/favorites") && !reply->url().path().contains("/favorites/")) {
        if (reply->operation() == QNetworkAccessManager::GetOperation) {
            // Processing list of favorites
            m_favorites.clear();
            if (jsonObject.contains("favorites") && jsonObject["favorites"].isArray()) {
                QJsonArray favoritesArray = jsonObject["favorites"].toArray();
                for (const QJsonValue &value : favoritesArray) {
                    m_favorites.append(value.toObject()["id"].toString());
                }
            }
            emit favoritesUpdated(m_favorites);
        } else if (reply->operation() == QNetworkAccessManager::PostOperation) {
            // Added a favorite
            if (jsonObject.contains("restaurant_id")) {
                QString restaurantId = jsonObject["restaurant_id"].toString();
                if (!m_favorites.contains(restaurantId)) {
                    m_favorites.append(restaurantId);
                }
                emit favoriteAdded(restaurantId);
            }
        }
    } else if (urlPath.contains("/favorites/") && reply->operation() == QNetworkAccessManager::DeleteOperation) {
        // Removed a favorite
        QStringList parts = urlPath.split("/");
        if (parts.length() >= 3) {
            QString restaurantId = parts.last();
            m_favorites.removeAll(restaurantId);
            emit favoriteRemoved(restaurantId);
        }
    }

    reply->deleteLater();
}

void UserController::setUsername(const QString &username)
{
    if (m_username != username) {
        m_username = username;
        emit userDataChanged();
    }
}

void UserController::setAuthToken(const QString &token)
{
    if (m_authToken != token) {
        m_authToken = token;
    }
}

void UserController::setErrorMessage(const QString &message)
{
    if (m_errorMessage != message) {
        m_errorMessage = message;
        emit errorMessageChanged();
    }
}

void UserController::setLoading(bool loading)
{
    if (m_loading != loading) {
        m_loading = loading;
        emit loadingChanged();
    }
}

void UserController::loadStoredCredentials()
{
    QSettings settings;
    m_username = settings.value("user/username").toString();
    m_authToken = settings.value("user/authToken").toString();

    if (!m_authToken.isEmpty()) {
        emit authStateChanged();
        getUserProfile();
    }
}

void UserController::saveCredentials()
{
    QSettings settings;
    settings.setValue("user/username", m_username);
    settings.setValue("user/authToken", m_authToken);
}

void UserController::clearCredentials()
{
    m_username = "";
    m_authToken = "";
    m_favorites.clear();

    QSettings settings;
    settings.remove("user/username");
    settings.remove("user/authToken");
}
