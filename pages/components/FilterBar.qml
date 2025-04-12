import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: filterBar
    
    // Properties
    property string currentFilter: "all"
    
    // Signals
    signal filterChanged(string filter)
    
    color: "#f5f5f5"
    
    // Filter buttons
    RowLayout {
        anchors {
            fill: parent
            leftMargin: 10
            rightMargin: 10
        }
        spacing: 10
        
        // All button
        Rectangle {
            Layout.preferredWidth: allText.width + 20
            Layout.fillHeight: true
            radius: 8
            color: currentFilter === "all" ? "#4caf50" : "white"
            border.color: currentFilter === "all" ? "#4caf50" : "#e0e0e0"
            
            Text {
                id: allText
                text: "All"
                anchors.centerIn: parent
                color: currentFilter === "all" ? "white" : "#424242"
                font.pixelSize: 14
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    currentFilter = "all"
                    filterChanged("all")
                }
            }
        }
        
        // Vegan button
        Rectangle {
            Layout.preferredWidth: veganText.width + 20
            Layout.fillHeight: true
            radius: 8
            color: currentFilter === "vegan" ? "#4caf50" : "white"
            border.color: currentFilter === "vegan" ? "#4caf50" : "#e0e0e0"
            
            Text {
                id: veganText
                text: "Vegan"
                anchors.centerIn: parent
                color: currentFilter === "vegan" ? "white" : "#424242"
                font.pixelSize: 14
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    currentFilter = "vegan"
                    filterChanged("vegan")
                }
            }
        }
        
        // Vegetarian button
        Rectangle {
            Layout.preferredWidth: vegetarianText.width + 20
            Layout.fillHeight: true
            radius: 8
            color: currentFilter === "vegetarian" ? "#4caf50" : "white"
            border.color: currentFilter === "vegetarian" ? "#4caf50" : "#e0e0e0"
            
            Text {
                id: vegetarianText
                text: "Vegetarian"
                anchors.centerIn: parent
                color: currentFilter === "vegetarian" ? "white" : "#424242"
                font.pixelSize: 14
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    currentFilter = "vegetarian"
                    filterChanged("vegetarian")
                }
            }
        }
        
        // Top rated button
        Rectangle {
            Layout.preferredWidth: ratingText.width + 20
            Layout.fillHeight: true
            radius: 8
            color: currentFilter === "rating" ? "#4caf50" : "white"
            border.color: currentFilter === "rating" ? "#4caf50" : "#e0e0e0"
            
            Text {
                id: ratingText
                text: "Top Rated"
                anchors.centerIn: parent
                color: currentFilter === "rating" ? "white" : "#424242"
                font.pixelSize: 14
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    currentFilter = "rating"
                    filterChanged("rating")
                }
            }
        }
        
        Item {
            Layout.fillWidth: true
        }
    }
}
