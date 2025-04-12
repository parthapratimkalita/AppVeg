#include "ResturantModel.h"
#include <QJsonObject>
#include <QGeoCoordinate>

RestaurantModel::RestaurantModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int RestaurantModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_restaurants.size();
}

QVariant RestaurantModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_restaurants.size())
        return QVariant();

    const Restaurant &restaurant = m_restaurants.at(index.row());

    switch (role) {
    case IdRole:
        return restaurant.id;
    case NameRole:
        return restaurant.name;
    case AddressRole:
        return restaurant.address;
    case PhoneNumberRole:
        return restaurant.phoneNumber;
    case WebsiteRole:
        return restaurant.website;
    case CuisineTypeRole:
        return restaurant.cuisineType;
    case DescriptionRole:
        return restaurant.description;
    case LatitudeRole:
        return restaurant.latitude;
    case LongitudeRole:
        return restaurant.longitude;
    case RatingRole:
        return restaurant.rating;
    case IsVeganRole:
        return restaurant.isVegan;
    case IsVegetarianRole:
        return restaurant.isVegetarian;
    case PhotosRole:
        return QVariant::fromValue(restaurant.photos);
    case DistanceRole:
        return restaurant.distance;
    case IsFavoriteRole:
        return restaurant.isFavorite;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> RestaurantModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[NameRole] = "name";
    roles[AddressRole] = "address";
    roles[PhoneNumberRole] = "phoneNumber";
    roles[WebsiteRole] = "website";
    roles[CuisineTypeRole] = "cuisineType";
    roles[DescriptionRole] = "description";
    roles[LatitudeRole] = "latitude";
    roles[LongitudeRole] = "longitude";
    roles[RatingRole] = "rating";
    roles[IsVeganRole] = "isVegan";
    roles[IsVegetarianRole] = "isVegetarian";
    roles[PhotosRole] = "photos";
    roles[DistanceRole] = "distance";
    roles[IsFavoriteRole] = "isFavorite";
    return roles;
}

QVariantMap RestaurantModel::get(int index) const
{
    if (index < 0 || index >= m_restaurants.size())
        return QVariantMap();

    const Restaurant &restaurant = m_restaurants.at(index);
    QVariantMap map;

    map["id"] = restaurant.id;
    map["name"] = restaurant.name;
    map["address"] = restaurant.address;
    map["phoneNumber"] = restaurant.phoneNumber;
    map["website"] = restaurant.website;
    map["cuisineType"] = restaurant.cuisineType;
    map["description"] = restaurant.description;
    map["latitude"] = restaurant.latitude;
    map["longitude"] = restaurant.longitude;
    map["rating"] = restaurant.rating;
    map["isVegan"] = restaurant.isVegan;
    map["isVegetarian"] = restaurant.isVegetarian;
    map["photos"] = QVariant::fromValue(restaurant.photos);
    map["distance"] = restaurant.distance;
    map["isFavorite"] = restaurant.isFavorite;

    return map;
}

void RestaurantModel::toggleFavorite(int index)
{
    if (index < 0 || index >= m_restaurants.size())
        return;

    m_restaurants[index].isFavorite = !m_restaurants[index].isFavorite;

    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {IsFavoriteRole});
    emit favoriteToggled(m_restaurants[index].id, m_restaurants[index].isFavorite);
}

void RestaurantModel::setFavoriteStatus(const QString &id, bool isFavorite)
{
    for (int i = 0; i < m_restaurants.size(); ++i) {
        if (m_restaurants[i].id == id) {
            m_restaurants[i].isFavorite = isFavorite;
            QModelIndex modelIndex = createIndex(i, 0);
            emit dataChanged(modelIndex, modelIndex, {IsFavoriteRole});
            break;
        }
    }
}

void RestaurantModel::updateFromJson(const QJsonArray &jsonArray)
{
    beginResetModel();

    m_restaurants.clear();

    for (const QJsonValue &value : jsonArray) {
        QJsonObject obj = value.toObject();

        Restaurant restaurant;
        restaurant.id = obj["id"].toString();
        restaurant.name = obj["name"].toString();
        restaurant.address = obj["address"].toString();
        restaurant.phoneNumber = obj["phone_number"].toString();
        restaurant.website = obj["website"].toString();
        restaurant.cuisineType = obj["cuisine_type"].toString();
        restaurant.description = obj["description"].toString();
        restaurant.latitude = obj["latitude"].toDouble();
        restaurant.longitude = obj["longitude"].toDouble();
        restaurant.rating = obj["rating"].toInt();
        restaurant.isVegan = obj["is_vegan"].toBool();
        restaurant.isVegetarian = obj["is_vegetarian"].toBool();
        restaurant.distance = obj["distance"].toDouble(0.0);
        restaurant.isFavorite = obj["is_favorite"].toBool(false);

        // Parse photos array if exists
        if (obj.contains("photos") && obj["photos"].isArray()) {
            QJsonArray photosArray = obj["photos"].toArray();
            for (const QJsonValue &photoValue : photosArray) {
                restaurant.photos.append(photoValue.toString());
            }
        }

        m_restaurants.append(restaurant);
    }

    endResetModel();
}

void RestaurantModel::clear()
{
    beginResetModel();
    m_restaurants.clear();
    endResetModel();
}
