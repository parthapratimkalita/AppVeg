import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: profilePage
    
    // Signals
    signal backClicked()
    signal logoutSuccessful()
    
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
                text: "My Profile"
                font.pixelSize: 20
                font.bold: true
                elide: Label.ElideRight
                Layout.fillWidth: true
            }
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f5f5f5"
        
        ColumnLayout {
            anchors {
                fill: parent
                margins: 20
            }
            spacing: 20
            
            // User avatar and info
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                color: "white"
                radius: 10
                border.color: "#e0e0e0"
                
                RowLayout {
                    anchors {
                        fill: parent
                        margins: 20
                    }
                    spacing: 20
                    
                    // Avatar circle
                    Rectangle {
                        width: 80
                        height: 80
                        radius: 40
                        color: "#e8f5e9"
                        
                        Label {
                            anchors.centerIn: parent
                            text: userController.username.charAt(0).toUpperCase()
                            font.pixelSize: 32
                            font.bold: true
                            color: "#4caf50"
                        }
                    }
                    
                    // User info
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Label {
                            text: userController.username
                            font.pixelSize: 24
                            font.bold: true
                            color: "#424242"
                        }
                        
                        Label {
                            text: "Joined 2023"
                            color: "#757575"
                            font.pixelSize: 14
                        }
                    }
                }
            }
            
            // Stats
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 15
                rowSpacing: 15
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    color: "white"
                    radius: 10
                    border.color: "#e0e0e0"
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 5
                        
                        Label {
                            text: "Favorites"
                            font.pixelSize: 14
                            color: "#757575"
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Label {
                            text: "0"  // Will need to connect to actual data
                            font.pixelSize: 24
                            font.bold: true
                            color: "#424242"
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    color: "white"
                    radius: 10
                    border.color: "#e0e0e0"
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 5
                        
                        Label {
                            text: "Reviews"
                            font.pixelSize: 14
                            color: "#757575"
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Label {
                            text: "0"  // Will need to connect to actual data
                            font.pixelSize: 24
                            font.bold: true
                            color: "#424242"
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
            
            // Settings and options
            Rectangle {
                Layout.fillWidth: true
                color: "white"
                radius: 10
                border.color: "#e0e0e0"
                
                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: 0
                    }
                    spacing: 0
                    
                    // Settings item
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        color: settingsMouseArea.pressed ? "#f5f5f5" : "transparent"
                        
                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 20
                                rightMargin: 20
                            }
                            spacing: 15
                            
                            Image {
                                source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/settings.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                                

                            }
                            
                            Label {
                                text: "Settings"
                                font.pixelSize: 16
                                color: "#424242"
                                Layout.fillWidth: true
                            }
                            
                            Image {
                                source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/chevron-right.svg"
                                sourceSize.width: 20
                                sourceSize.height: 20
                                

                            }
                        }
                        
                        MouseArea {
                            id: settingsMouseArea
                            anchors.fill: parent
                            onClicked: {
                                // Settings action
                            }
                        }
                    }
                    
                    // Divider
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#f0f0f0"
                    }
                    
                    // Preferences item
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        color: preferencesMouseArea.pressed ? "#f5f5f5" : "transparent"
                        
                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 20
                                rightMargin: 20
                            }
                            spacing: 15
                            
                            Image {
                                source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/sliders.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                                

                            }
                            
                            Label {
                                text: "Preferences"
                                font.pixelSize: 16
                                color: "#424242"
                                Layout.fillWidth: true
                            }
                            
                            Image {
                                source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/chevron-right.svg"
                                sourceSize.width: 20
                                sourceSize.height: 20
                                

                            }
                        }
                        
                        MouseArea {
                            id: preferencesMouseArea
                            anchors.fill: parent
                            onClicked: {
                                // Preferences action
                            }
                        }
                    }
                    
                    // Divider
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#f0f0f0"
                    }
                    
                    // Help item
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        color: helpMouseArea.pressed ? "#f5f5f5" : "transparent"
                        
                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 20
                                rightMargin: 20
                            }
                            spacing: 15
                            
                            Image {
                                source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/help-circle.svg"
                                sourceSize.width: 24
                                sourceSize.height: 24
                                

                            }
                            
                            Label {
                                text: "Help & Support"
                                font.pixelSize: 16
                                color: "#424242"
                                Layout.fillWidth: true
                            }
                            
                            Image {
                                source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/chevron-right.svg"
                                sourceSize.width: 20
                                sourceSize.height: 20
                                

                            }
                        }
                        
                        MouseArea {
                            id: helpMouseArea
                            anchors.fill: parent
                            onClicked: {
                                // Help action
                            }
                        }
                    }
                }
            }
            
            // Logout button
            Button {
                text: "Log Out"
                Layout.fillWidth: true
                Layout.topMargin: 20
                
                background: Rectangle {
                    implicitHeight: 50
                    color: logoutButton.pressed ? "#b71c1c" : "#d32f2f"
                    radius: 8
                }
                
                contentItem: Text {
                    text: "Log Out"
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                id: logoutButton
                onClicked: {
                    logoutDialog.open()
                }
            }
            
            Item {
                Layout.fillHeight: true
            }
        }
    }
    
    // Logout confirmation dialog
    Dialog {
        id: logoutDialog
        title: "Log Out"
        standardButtons: Dialog.Yes | Dialog.No
        modal: true
        anchors.centerIn: Overlay.overlay
        
        Label {
            text: "Are you sure you want to log out?"
            wrapMode: Text.WordWrap
            width: parent.width
        }
        
        onAccepted: {
            userController.logout()
            logoutSuccessful()
        }
    }
}
