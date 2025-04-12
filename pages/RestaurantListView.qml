import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
//import VegFinder 1.0
import "components"

Page {
    id: restaurantListPage
    
    // Signals
    signal backClicked()
    signal restaurantSelected(string restaurantId)
    
    // Properties
    property string currentFilter: "all"
    
    Component.onCompleted: {
        // Refresh restaurants on page load
        appController.refreshRestaurants()
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
                text: "Restaurants"
                font.pixelSize: 20
                font.bold: true
                elide: Label.ElideRight
                Layout.fillWidth: true
            }
            
            ToolButton {
                icon.source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/refresh-cw.svg"
                onClicked: appController.refreshRestaurants()
                enabled: !appController.loading
            }
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Search bar
        SearchBar {
            id: searchBar
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            
            onQueryChanged: {
                    if (query.length >= 3) {
                        appController.searchRestaurants(query)
                    } else if (query.length === 0) {
                        appController.refreshRestaurants()
                    }
                }
        }
        
        // Filter bar
        FilterBar {
            id: filterBar
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            
            onFilterChanged: {
                currentFilter = filter
                if (filter === "all") {
                    appController.refreshRestaurants()
                } else if (filter === "vegan") {
                    appController.searchRestaurants("vegan")
                } else if (filter === "vegetarian") {
                    appController.searchRestaurants("vegetarian")
                } else if (filter === "rating") {
                    appController.searchRestaurants("", 5000, "", 4)
                }
            }
        }
        
        // Restaurant list
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            
            ListView {
                id: restaurantListView
                width: parent.width
                model: restaurantModel
                clip: true
                
                delegate: RestaurantCard {
                    width: restaurantListView.width
                    restaurantName: model.name
                    restaurantAddress: model.address
                    restaurantDistance: model.distance
                    restaurantRating: model.rating
                    isVegan: model.isVegan
                    isVegetarian: model.isVegetarian
                    isFavorite: model.isFavorite
                    
                    onClicked: {
                        restaurantSelected(model.id)
                    }
                    
                    onFavoriteToggled: {
                        restaurantModel.toggleFavorite(index)
                    }
                }
                
                // Empty state
                Item {
                    anchors.fill: parent
                    visible: restaurantListView.count === 0 && !appController.loading
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 20
                        
                        Image {
                            source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/search.svg"
                            sourceSize.width: 48
                            sourceSize.height: 48
                            Layout.alignment: Qt.AlignHCenter

                        }
                        
                        Label {
                            text: "No restaurants found"
                            font.pixelSize: 18
                            color: "#757575"
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Label {
                            text: "Try changing your search or filters"
                            font.pixelSize: 14
                            color: "#9e9e9e"
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Button {
                            text: "Refresh"
                            Layout.alignment: Qt.AlignHCenter
                            onClicked: appController.refreshRestaurants()
                        }
                    }
                }
            }
        }
    }
    
    // Loading indicator
    BusyIndicator {
        anchors.centerIn: parent
        running: appController.loading
        width: 48
        height: 48
    }
}
