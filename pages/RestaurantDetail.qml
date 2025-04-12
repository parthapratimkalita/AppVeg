import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: detailPage
    
    // Properties
    property string restaurantId: ""
    property var restaurantData: null
    
    // Signals
    signal backClicked()
    signal showOnMap()
    
    Component.onCompleted: {
        // Find restaurant in the model by ID
        for (var i = 0; i < restaurantModel.rowCount(); i++) {
            var restaurant = restaurantModel.get(i)
            if (restaurant.id === restaurantId) {
                restaurantData = restaurant
                break
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
                text: restaurantData ? restaurantData.name : "Restaurant Details"
                font.pixelSize: 20
                font.bold: true
                elide: Label.ElideRight
                Layout.fillWidth: true
            }
            
            ToolButton {
                id: favoriteButton
                icon.source: restaurantData && restaurantData.isFavorite ? 
                    "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/heart.svg" :
                    "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/heart.svg"
                
                contentItem: Image {
                    source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/heart.svg"
                    sourceSize.width: 24
                    sourceSize.height: 24
                    fillMode: Image.PreserveAspectFit
                    

                }
                
                onClicked: {
                    // Find index in model to toggle favorite
                    for (var i = 0; i < restaurantModel.rowCount(); i++) {
                        var restaurant = restaurantModel.get(i)
                        if (restaurant.id === restaurantId) {
                            restaurantModel.toggleFavorite(i)
                            // Update local data
                            restaurantData.isFavorite = !restaurantData.isFavorite
                            break
                        }
                    }
                }
            }
        }
    }
    
    ScrollView {
        anchors.fill: parent
        contentWidth: width
        
        ColumnLayout {
            width: parent.width
            spacing: 20
            
            // Restaurant doesn't exist state
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                visible: !restaurantData
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 10
                    
                    Label {
                        text: "Restaurant not found"
                        font.pixelSize: 18
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Button {
                        text: "Go Back"
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: backClicked()
                    }
                }
            }
            
            // Restaurant details
            ColumnLayout {
                visible: restaurantData !== null
                Layout.fillWidth: true
                Layout.margins: 15
                spacing: 15
                
                // Tags row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Rectangle {
                        color: "#e8f5e9"
                        radius: 4
                        height: tagVeganLabel.height + 10
                        Layout.preferredWidth: tagVeganLabel.width + 16
                        visible: restaurantData && restaurantData.isVegan
                        
                        Label {
                            id: tagVeganLabel
                            text: "Vegan"
                            color: "#2e7d32"
                            font.pixelSize: 14
                            anchors.centerIn: parent
                        }
                    }
                    
                    Rectangle {
                        color: "#f1f8e9"
                        radius: 4
                        height: tagVegetarianLabel.height + 10
                        Layout.preferredWidth: tagVegetarianLabel.width + 16
                        visible: restaurantData && restaurantData.isVegetarian && !restaurantData.isVegan
                        
                        Label {
                            id: tagVegetarianLabel
                            text: "Vegetarian"
                            color: "#558b2f"
                            font.pixelSize: 14
                            anchors.centerIn: parent
                        }
                    }
                    
                    Rectangle {
                        color: "#f3e5f5"
                        radius: 4
                        height: tagCuisineLabel.height + 10
                        Layout.preferredWidth: tagCuisineLabel.width + 16
                        visible: restaurantData && restaurantData.cuisineType !== ""
                        
                        Label {
                            id: tagCuisineLabel
                            text: restaurantData ? restaurantData.cuisineType : ""
                            color: "#7b1fa2"
                            font.pixelSize: 14
                            anchors.centerIn: parent
                        }
                    }
                    
                    Item {
                        Layout.fillWidth: true
                    }
                    
                    // Rating
                    Row {
                        spacing: 5
                        Layout.alignment: Qt.AlignRight
                        
                        Image {
                            source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/star.svg"
                            width: 18
                            height: 18
                            anchors.verticalCenter: parent.verticalCenter
                            

                        }
                        
                        Label {
                            text: restaurantData ? restaurantData.rating : "0"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#424242"
                        }
                    }
                }
                
                // Address
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Image {
                        source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/map-pin.svg"
                        sourceSize.width: 20
                        sourceSize.height: 20
                        Layout.alignment: Qt.AlignTop
                        

                    }
                    
                    Label {
                        text: restaurantData ? restaurantData.address : ""
                        font.pixelSize: 15
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        color: "#424242"
                    }
                }
                
                // Distance
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Image {
                        source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/navigation.svg"
                        sourceSize.width: 20
                        sourceSize.height: 20
                        

                    }
                    
                    Label {
                        text: restaurantData ? 
                              (restaurantData.distance < 1000 ? 
                              Math.round(restaurantData.distance) + " m" : 
                              (restaurantData.distance / 1000).toFixed(1) + " km") : ""
                        font.pixelSize: 15
                        color: "#424242"
                    }
                }
                
                // Phone
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    visible: restaurantData && restaurantData.phoneNumber !== ""
                    
                    Image {
                        source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/phone.svg"
                        sourceSize.width: 20
                        sourceSize.height: 20
                        

                    }
                    
                    Label {
                        text: restaurantData ? restaurantData.phoneNumber : ""
                        font.pixelSize: 15
                        color: "#2196f3"
                    }
                }
                
                // Website
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    visible: restaurantData && restaurantData.website !== ""
                    
                    Image {
                        source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/globe.svg"
                        sourceSize.width: 20
                        sourceSize.height: 20
                        

                    }
                    
                    Label {
                        text: restaurantData ? restaurantData.website : ""
                        font.pixelSize: 15
                        color: "#2196f3"
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (restaurantData && restaurantData.website) {
                                    Qt.openUrlExternally(restaurantData.website)
                                }
                            }
                        }
                    }
                }
                
                // Divider
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#e0e0e0"
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                }
                
                // Description
                Label {
                    text: "Description"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#424242"
                    visible: restaurantData && restaurantData.description !== ""
                }
                
                Label {
                    text: restaurantData ? restaurantData.description : ""
                    font.pixelSize: 15
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    color: "#616161"
                    visible: restaurantData && restaurantData.description !== ""
                }
                
                // Divider
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#e0e0e0"
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                }
                
                // Map preview
                Label {
                    text: "Location"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#424242"
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    color: "#f5f5f5"
                    border.color: "#e0e0e0"
                    
                    Label {
                        anchors.centerIn: parent
                        text: "Map Preview"
                        font.pixelSize: 16
                        color: "#9e9e9e"
                    }
                    
                    Button {
                        anchors {
                            bottom: parent.bottom
                            right: parent.right
                            margins: 10
                        }
                        text: "View on Map"
                        onClicked: showOnMap()
                    }
                }
                
                // Bottom spacing
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                }
            }
        }
    }
}
