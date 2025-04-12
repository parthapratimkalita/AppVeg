import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtLocation 5.15
import QtPositioning 5.15

Page {
    id: mapPage
    
    // Properties
    property string focusRestaurantId: ""
    
    // Signals
    signal backClicked()
    signal restaurantSelected(string restaurantId)
    
    Component.onCompleted: {
        // Request fresh data when map opens
        appController.refreshRestaurants()
        
        // Set map center to user location
        if (appController.locationPermissionGranted) {
            map.center = QtPositioning.coordinate(appController.userLatitude, appController.userLongitude)
        }
        
        // If a restaurant ID is provided, focus on it
        if (focusRestaurantId !== "") {
            for (var i = 0; i < restaurantModel.rowCount(); i++) {
                var restaurant = restaurantModel.get(i)
                if (restaurant.id === focusRestaurantId) {
                    map.center = QtPositioning.coordinate(restaurant.latitude, restaurant.longitude)
                    map.zoomLevel = 15
                    break
                }
            }
        }
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
                text: "Map View"
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
    
    // Map with restaurants
    Map {
        id: map
        anchors.fill: parent
        plugin: Plugin { name: "osm" } // OpenStreetMap
        zoomLevel: 14
        
        // User position marker
        MapQuickItem {
            id: userMarker
            anchorPoint.x: userMarkerImage.width/2
            anchorPoint.y: userMarkerImage.height
            coordinate: QtPositioning.coordinate(appController.userLatitude, appController.userLongitude)
            visible: appController.locationPermissionGranted
            
            sourceItem: Item {
                width: 24
                height: 24
                
                Image {
                    id: userMarkerImage
                    anchors.fill: parent
                    source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/circle.svg"
                    

                }
            }
        }
        
        // Restaurant markers from model
        MapItemView {
            model: restaurantModel
            delegate: MapQuickItem {
                id: restaurantMarker
                anchorPoint.x: restaurantMarkerImage.width/2
                anchorPoint.y: restaurantMarkerImage.height
                coordinate: QtPositioning.coordinate(model.latitude, model.longitude)
                zoomLevel: 0
                
                sourceItem: Item {
                    width: 30
                    height: 30
                    
                    Image {
                        id: restaurantMarkerImage
                        anchors.fill: parent
                        source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/map-pin.svg"
                        

                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            markerPopup.restaurantId = model.id
                            markerPopup.restaurantName = model.name
                            markerPopup.restaurantAddress = model.address
                            markerPopup.isVegan = model.isVegan
                            markerPopup.isVegetarian = model.isVegetarian
                            markerPopup.open()
                        }
                    }
                }
            }
        }
        
        // Location button
        Rectangle {
            anchors {
                right: parent.right
                bottom: parent.bottom
                margins: 20
            }
            width: 50
            height: 50
            radius: 25
            color: "#ffffff"
            border.color: "#e0e0e0"
            
            Image {
                anchors.centerIn: parent
                source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/navigation.svg"
                width: 24
                height: 24

            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (appController.locationPermissionGranted) {
                        map.center = QtPositioning.coordinate(appController.userLatitude, appController.userLongitude)
                        map.zoomLevel = 15
                    } else {
                        locationPermissionDialog.open()
                    }
                }
            }
        }
        
        // Zoom controls
        Column {
            anchors {
                right: parent.right
                top: parent.top
                margins: 20
            }
            spacing: 10
            
            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: "#ffffff"
                border.color: "#e0e0e0"
                
                Text {
                    anchors.centerIn: parent
                    text: "+"
                    font.pixelSize: 24
                    color: "#424242"
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: map.zoomLevel++
                }
            }
            
            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: "#ffffff"
                border.color: "#e0e0e0"
                
                Text {
                    anchors.centerIn: parent
                    text: "-"
                    font.pixelSize: 24
                    color: "#424242"
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: map.zoomLevel--
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
    
    // Restaurant popup when marker is clicked
    Popup {
        id: markerPopup
        width: parent.width * 0.8
        height: column.height + 30
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        // Properties
        property string restaurantId: ""
        property string restaurantName: ""
        property string restaurantAddress: ""
        property bool isVegan: false
        property bool isVegetarian: false
        
        ColumnLayout {
            id: column
            width: parent.width
            spacing: 10
            
            Label {
                text: markerPopup.restaurantName
                font.pixelSize: 18
                font.bold: true
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Rectangle {
                    color: "#e8f5e9"
                    radius: 4
                    height: veganLabel.height + 6
                    Layout.preferredWidth: veganLabel.width + 12
                    visible: markerPopup.isVegan
                    
                    Label {
                        id: veganLabel
                        text: "Vegan"
                        color: "#2e7d32"
                        font.pixelSize: 12
                        anchors.centerIn: parent
                    }
                }
                
                Rectangle {
                    color: "#f1f8e9"
                    radius: 4
                    height: vegetarianLabel.height + 6
                    Layout.preferredWidth: vegetarianLabel.width + 12
                    visible: markerPopup.isVegetarian && !markerPopup.isVegan
                    
                    Label {
                        id: vegetarianLabel
                        text: "Vegetarian"
                        color: "#558b2f"
                        font.pixelSize: 12
                        anchors.centerIn: parent
                    }
                }
            }
            
            Label {
                text: markerPopup.restaurantAddress
                font.pixelSize: 14
                color: "#616161"
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Button {
                    text: "Details"
                    Layout.fillWidth: true
                    
                    onClicked: {
                        restaurantSelected(markerPopup.restaurantId)
                        markerPopup.close()
                    }
                }
                
                Button {
                    text: "Close"
                    Layout.fillWidth: true
                    
                    onClicked: {
                        markerPopup.close()
                    }
                }
            }
        }
    }
    
    // Location permission dialog
    Dialog {
        id: locationPermissionDialog
        title: "Location Access"
        standardButtons: Dialog.Yes | Dialog.No
        modal: true
        
        Label {
            text: "To show your location on the map, the app needs permission to access your location. Enable location access?"
            wrapMode: Text.WordWrap
            width: parent.width
        }
        
        onAccepted: {
            appController.requestLocationPermission()
        }
    }
}
