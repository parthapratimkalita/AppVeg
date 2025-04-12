import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
//import VegFinder 1.0
import "components"

Page {
    id: favoritesPage
    
    // Signals
    signal backClicked()
    signal restaurantSelected(string restaurantId)
    
    Component.onCompleted: {
        // Get user's favorite restaurants
        userController.getFavorites()
    }
    
    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            
            ToolButton {
                icon.source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/arrow-left.svg"
                onClicked: backClicked()
            }
            
            Label {
                text: "My Favorites"
                font.pixelSize: 20
                font.bold: true
                elide: Label.ElideRight
                Layout.fillWidth: true
            }
            
            ToolButton {
                icon.source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/refresh-cw.svg"
                onClicked: userController.getFavorites()
                enabled: !userController.loading
            }
        }
    }
    
    // Favorites list
    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        
        ListView {
            id: favoritesList
            width: parent.width
            model: restaurantModel
            clip: true
            
            // Custom filter to show only favorites
            section.property: "isFavorite"
            section.criteria: ViewSection.FullString
            section.delegate: Item { visible: false; height: 0 }
            
            // Filters the model to only show favorites
            Component.onCompleted: {
                favoritesList.model = restaurantModel
            }
            
            delegate: RestaurantCard {
                width: favoritesList.width
                restaurantName: model.name
                restaurantAddress: model.address
                restaurantDistance: model.distance
                restaurantRating: model.rating
                isVegan: model.isVegan
                isVegetarian: model.isVegetarian
                isFavorite: model.isFavorite
                visible: model.isFavorite
                height: model.isFavorite ? implicitHeight : 0
                
                onClicked: {
                    if (model.isFavorite) {
                        restaurantSelected(model.id)
                    }
                }
                
                onFavoriteToggled: {
                    restaurantModel.toggleFavorite(index)
                }
            }
            
            // Empty state
            Item {
                anchors.fill: parent
                visible: !hasVisibleItems() && !userController.loading
                
                function hasVisibleItems() {
                    for (var i = 0; i < restaurantModel.rowCount(); i++) {
                        var restaurant = restaurantModel.get(i)
                        if (restaurant.isFavorite) {
                            return true
                        }
                    }
                    return false
                }
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 20
                    
                    Image {
                        source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/heart.svg"
                        sourceSize.width: 48
                        sourceSize.height: 48
                        Layout.alignment: Qt.AlignHCenter
                        
                    }
                    
                    Label {
                        text: "No favorites yet"
                        font.pixelSize: 18
                        color: "#757575"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Label {
                        text: "Add restaurants to your favorites to see them here"
                        font.pixelSize: 14
                        color: "#9e9e9e"
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        Layout.maximumWidth: parent.width
                    }
                    
                    Button {
                        text: "Browse Restaurants"
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: {
                            backClicked()
                        }
                    }
                }
            }
        }
    }
    
    // Loading indicator
    BusyIndicator {
        anchors.centerIn: parent
        running: userController.loading
        width: 48
        height: 48
    }
}
