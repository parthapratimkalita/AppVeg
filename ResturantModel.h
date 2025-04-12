#ifndef RESTAURANTMODEL_H
#define RESTAURANTMODEL_H

#include <QAbstractListModel>
#include <QGeoCoordinate>
#include <QJsonArray>
#include <QVector>

class Restaurant {
public:
    QString id;
    QString name;
    QString address;
    QString phoneNumber;
    QString website;
    QString cuisineType;
    QString description;
    double latitude;
    double longitude;
    int rating;
    bool isVegan;
    bool isVegetarian;
    QStringList photos;
    double distance;
    bool isFavorite;
};

class RestaurantModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum RestaurantRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        AddressRole,
        PhoneNumberRole,
        WebsiteRole,
        CuisineTypeRole,
        DescriptionRole,
        LatitudeRole,
        LongitudeRole,
        RatingRole,
        IsVeganRole,
        IsVegetarianRole,
        PhotosRole,
        DistanceRole,
        IsFavoriteRole
    };

    explicit RestaurantModel(QObject *parent = nullptr);

    // QAbstractItemModel implementation
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Custom methods
    Q_INVOKABLE QVariantMap get(int index) const;
    Q_INVOKABLE void toggleFavorite(int index);
    Q_INVOKABLE void setFavoriteStatus(const QString &id, bool isFavorite);

    void updateFromJson(const QJsonArray &jsonArray);
    void clear();

signals:
    void favoriteToggled(const QString &id, bool isFavorite);

private:
    QVector<Restaurant> m_restaurants;
};

#endif // RESTAURANTMODEL_H
