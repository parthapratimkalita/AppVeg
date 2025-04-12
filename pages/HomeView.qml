import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtLocation 5.15
import QtPositioning 5.15

Page {
    id: homePage
    
    // Signals
    signal openRestaurantList()
    signal openMap()
    signal openLogin()
    signal openProfile()
    signal openFavorites()
    
    header: ToolBar {
        height: 60
        
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            
            Label {
                text: "VegFinder"
                font.pixelSize: 22
                font.bold: true
                elide: Label.ElideRight
                Layout.fillWidth: true
            }
            
            ToolButton {
                icon.source: userController.isLoggedIn ? 
                    "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/user.svg" :
                    "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/log-in.svg"
                onClicked: {
                    if (userController.isLoggedIn) {
                        openProfile()
                    } else {
                        openLogin()
                    }
                }
            }
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f5f5f5"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 30
            
            // App logo and welcome
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                color: "transparent"
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 10
                    
                    Label {
                        text: "🌱 VegFinder"
                        font.pixelSize: 32
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        color: "#4caf50"
                    }
                    
                    Label {
                        text: "Find Vegetarian & Vegan Places Near You"
                        font.pixelSize: 16
                        Layout.alignment: Qt.AlignHCenter
                        color: "#555555"
                    }
                }
            }
            
            // Main action buttons
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Button {
                    text: "Find Nearby Restaurants"
                    icon.source: "assets/icons/explore.svg"
                    Layout.fillWidth: true
                    height: 60
                    
                    background: Rectangle {
                        color: "#4caf50"
                        radius: 8
                    }
                    
                    contentItem: RowLayout {
                        spacing: 10
                        
                        Image {
                            source: "assets/icons/explore.svg"
                            sourceSize.width: 24
                            sourceSize.height: 24
                            Layout.alignment: Qt.AlignVCenter

                        }
                        
                        Label {
                            text: "Find Nearby Restaurants"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                            Layout.fillWidth: true
                        }
                    }
                    
                    onClicked: openRestaurantList()
                }
                
                Button {
                    text: "View Map"
                    icon.source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/map.svg"
                    Layout.fillWidth: true
                    height: 60
                    
                    background: Rectangle {
                        color: "#2196f3"
                        radius: 8
                    }
                    
                    contentItem: RowLayout {
                        spacing: 10
                        
                        Image {
                            source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/map.svg"
                            sourceSize.width: 24
                            sourceSize.height: 24
                            Layout.alignment: Qt.AlignVCenter

                        }
                        
                        Label {
                            text: "View Map"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                            Layout.fillWidth: true
                        }
                    }
                    
                    onClicked: openMap()
                }
                
                Button {
                    text: "My Favorites"
                    visible: userController.isLoggedIn
                    icon.source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/heart.svg"
                    Layout.fillWidth: true
                    height: 60
                    
                    background: Rectangle {
                        color: "#e91e63"
                        radius: 8
                    }
                    
                    contentItem: RowLayout {
                        spacing: 10
                        
                        Image {
                            source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/heart.svg"
                            sourceSize.width: 24
                            sourceSize.height: 24
                            Layout.alignment: Qt.AlignVCenter

                        }
                        
                        Label {
                            text: "My Favorites"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                            Layout.fillWidth: true
                        }
                    }
                    
                    onClicked: openFavorites()
                }
            }
            
            // Location status
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "#e8f5e9"
                radius: 8
                visible: !appController.locationPermissionGranted
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15
                    
                    Image {
                        source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/map-pin.svg"
                        sourceSize.width: 24
                        sourceSize.height: 24
                        Layout.alignment: Qt.AlignVCenter

                    }
                    
                    Label {
                        text: "Enable location services to find restaurants near you"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        color: "#2e7d32"
                    }
                    
                    Button {
                        text: "Enable"
                        Layout.alignment: Qt.AlignVCenter
                        
                        onClicked: appController.requestLocationPermission()
                    }
                }
            }
            
            // Quick info items
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 15
                columnSpacing: 15
                
                // Quick search by category buttons
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    radius: 8
                    color: "#e0f7fa"
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 5
                        
                        Image {
                            source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/coffee.svg"
                            sourceSize.width: 32
                            sourceSize.height: 32
                            Layout.alignment: Qt.AlignHCenter

                        }
                        
                        Label {
                            text: "Cafés"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignHCenter
                            color: "#00838f"
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appController.searchRestaurants("", 5000, "cafe")
                            openRestaurantList()
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    radius: 8
                    color: "#fff3e0"
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 5
                        
                        Image {
                            source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/shopping-bag.svg"
                            sourceSize.width: 32
                            sourceSize.height: 32
                            Layout.alignment: Qt.AlignHCenter

                        }
                        
                        Label {
                            text: "Food Stores"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignHCenter
                            color: "#ef6c00"
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appController.searchRestaurants("", 5000, "store")
                            openRestaurantList()
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    radius: 8
                    color: "#f3e5f5"
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 5
                        
                        Image {
                            source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/star.svg"
                            sourceSize.width: 32
                            sourceSize.height: 32
                            Layout.alignment: Qt.AlignHCenter

                        }
                        
                        Label {
                            text: "Top Rated"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignHCenter
                            color: "#7b1fa2"
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appController.searchRestaurants("", 5000, "", 4)
                            openRestaurantList()
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    radius: 8
                    color: "#e8f5e9"
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 5
                        
                        Image {
                            source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/check-circle.svg"
                            sourceSize.width: 32
                            sourceSize.height: 32
                            Layout.alignment: Qt.AlignHCenter

                        }
                        
                        Label {
                            text: "100% Vegan"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignHCenter
                            color: "#2e7d32"
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appController.searchRestaurants("vegan", 5000)
                            openRestaurantList()
                        }
                    }
                }
            }
            
            Item {
                Layout.fillHeight: true
            }
        }
    }
}
