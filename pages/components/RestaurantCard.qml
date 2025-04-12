import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: card
    
    // Properties
    property string restaurantName: ""
    property string restaurantAddress: ""
    property double restaurantDistance: 0.0
    property int restaurantRating: 0
    property bool isVegan: false
    property bool isVegetarian: false
    property bool isFavorite: false
    
    // Signals
    signal clicked()
    signal favoriteToggled()
    
    // Calculated properties
    property string distanceText: {
        if (restaurantDistance < 1000) {
            return Math.round(restaurantDistance) + " m";
        } else {
            return (restaurantDistance / 1000).toFixed(1) + " km";
        }
    }
    
    // Layout
    height: 120
    radius: 8
    color: "white"
    border.color: "#e0e0e0"
    
    // Click handler
    MouseArea {
        anchors.fill: parent
        onClicked: card.clicked()
    }
    
    RowLayout {
        anchors {
            fill: parent
            margins: 12
        }
        spacing: 12
        
        // Restaurant type icon
        Rectangle {
            width: 60
            height: 60
            radius: 30
            color: isVegan ? "#e8f5e9" : (isVegetarian ? "#f1f8e9" : "#fafafa")
            Layout.alignment: Qt.AlignVCenter
            
            Text {
                anchors.centerIn: parent
                text: isVegan ? "V" : "VG"
                font.pixelSize: 22
                font.bold: true
                color: isVegan ? "#2e7d32" : (isVegetarian ? "#558b2f" : "#9e9e9e")
            }
        }
        
        // Restaurant info
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4
            
            Label {
                text: restaurantName
                font.pixelSize: 16
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
                color: "#424242"
            }
            
            // Address
            RowLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Image {
                    source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/map-pin.svg"
                    sourceSize.width: 14
                    sourceSize.height: 14
                    

                }
                
                Label {
                    text: restaurantAddress
                    font.pixelSize: 13
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    color: "#757575"
                }
            }
            
            // Distance and rating row
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                
                // Distance
                RowLayout {
                    spacing: 4
                    
                    Image {
                        source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/navigation.svg"
                        sourceSize.width: 14
                        sourceSize.height: 14
                        

                    }
                    
                    Label {
                        text: distanceText
                        font.pixelSize: 13
                        color: "#757575"
                    }
                }
                
                // Rating
                RowLayout {
                    spacing: 4
                    
                    Image {
                        source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/star.svg"
                        sourceSize.width: 14
                        sourceSize.height: 14
                        

                    }
                    
                    Label {
                        text: restaurantRating
                        font.pixelSize: 13
                        color: "#757575"
                    }
                }
                
                Item {
                    Layout.fillWidth: true
                }
                
                // Tags
                Rectangle {
                    color: isVegan ? "#e8f5e9" : "#f1f8e9"
                    radius: 4
                    height: veganLabel.height + 6
                    implicitWidth: veganLabel.width + 12
                    visible: isVegan || isVegetarian
                    
                    Label {
                        id: veganLabel
                        text: isVegan ? "Vegan" : "Vegetarian"
                        color: isVegan ? "#2e7d32" : "#558b2f"
                        font.pixelSize: 12
                        anchors.centerIn: parent
                    }
                }
            }
        }
        
        // Favorite button
        Rectangle {
            width: 40
            height: 40
            radius: 20
            color: "transparent"
            
            Image {
                anchors.centerIn: parent
                source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/heart.svg"
                sourceSize.width: 22
                sourceSize.height: 22
                

            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    favoriteToggled()
                    // Don't propagate click to parent
                    mouse.accepted = true
                }
            }
        }
    }
}
