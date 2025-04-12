#ifndef APPCONTROLLER_H
#define APPCONTROLLER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QGeoPositionInfoSource>
#include <QGeoPositionInfo>
#include "ResturantModel.h"

class AppController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)
    Q_PROPERTY(RestaurantModel* restaurantModel READ restaurantModel CONSTANT)
    Q_PROPERTY(bool locationPermissionGranted READ locationPermissionGranted WRITE setLocationPermissionGranted NOTIFY locationPermissionGrantedChanged)
    Q_PROPERTY(double userLatitude READ userLatitude NOTIFY userLocationChanged)
    Q_PROPERTY(double userLongitude READ userLongitude NOTIFY userLocationChanged)
    Q_PROPERTY(QString authToken READ authToken NOTIFY authTokenChanged)
    Q_PROPERTY(bool isAuthenticated READ isAuthenticated NOTIFY isAuthenticatedChanged)

public:
    explicit AppController(QObject *parent = nullptr);
    ~AppController();

    bool loading() const;
    QString error() const;
    RestaurantModel* restaurantModel();
    bool locationPermissionGranted() const;
    void setLocationPermissionGranted(bool granted);
    double userLatitude() const;
    double userLongitude() const;
    QString authToken() const;
    bool isAuthenticated() const;

public slots:
    void initialize();
    void searchRestaurants(const QString &query, int radius = 5000, const QString &cuisineType = "", int rating = 0);
    void refreshRestaurants();
    void clearError();
    void requestLocationPermission();
    void login(const QString &username, const QString &password);
    void logout();
    void registerUser(const QString &username, const QString &password, const QString &email);

signals:
    void loadingChanged();
    void errorChanged();
    void locationPermissionGrantedChanged();
    void userLocationChanged();
    void authTokenChanged();
    void isAuthenticatedChanged();
    void loginSuccessful();
    void loginFailed(const QString &error);
    void registrationSuccessful();
    void registrationFailed(const QString &error);

private slots:
    void handleNetworkReply(QNetworkReply *reply);
    void onPositionUpdated(const QGeoPositionInfo &info);
    void onPositionError(QGeoPositionInfoSource::Error error);

private:
    QNetworkAccessManager *m_networkManager;
    QGeoPositionInfoSource *m_positionSource;
    RestaurantModel *m_restaurantModel;
    bool m_loading;
    QString m_error;
    bool m_locationPermissionGranted;
    double m_userLatitude;
    double m_userLongitude;
    QString m_baseUrl;
    QString m_authToken;
    bool m_isAuthenticated;

    void setLoading(bool loading);
    void setError(const QString &error);
    void updateUserLocation(double latitude, double longitude);
    void fetchNearbyRestaurants();
    void setAuthToken(const QString &token);
    void setAuthenticated(bool authenticated);
    QNetworkRequest createRequest(const QUrl &url);
    void handleAuthResponse(const QJsonDocument &doc);
    void handleRestaurantResponse(const QJsonDocument &doc);
};

#endif // APPCONTROLLER_H
