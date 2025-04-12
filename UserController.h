#ifndef USERCONTROLLER_H
#define USERCONTROLLER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJSValue>

class UserController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY authStateChanged)
    Q_PROPERTY(QString username READ username NOTIFY userDataChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit UserController(QObject *parent = nullptr);
    ~UserController();

    bool isLoggedIn() const;
    QString username() const;
    QString errorMessage() const;
    bool loading() const;

public slots:
    void login(const QString &username, const QString &password);
    void register_(const QString &username, const QString &email, const QString &password);
    void logout();
    void getUserProfile();
    void getFavorites();
    void addToFavorites(const QString &restaurantId);
    void removeFromFavorites(const QString &restaurantId);
    void clearError();

signals:
    void authStateChanged();
    void userDataChanged();
    void errorMessageChanged();
    void loadingChanged();
    void favoritesUpdated(const QStringList &favoriteIds);
    void favoriteAdded(const QString &restaurantId);
    void favoriteRemoved(const QString &restaurantId);

private slots:
    void handleNetworkReply(QNetworkReply *reply);

private:
    QNetworkAccessManager *m_networkManager;
    QString m_username;
    QString m_email;
    QString m_authToken;
    QString m_errorMessage;
    bool m_loading;
    QStringList m_favorites;
    QString m_authUrl;
    QString m_apiUrl;

    void setUsername(const QString &username);
    void setAuthToken(const QString &token);
    void setErrorMessage(const QString &message);
    void setLoading(bool loading);
    void loadStoredCredentials();
    void saveCredentials();
    void clearCredentials();
};

#endif // USERCONTROLLER_H
