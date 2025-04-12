import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: registerPage

    // Signals
    signal backClicked()
    signal registerSuccessful()

    // Email validation function
    function isValidEmail(email) {
        // Regular expression for basic email validation
        var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
        return emailRegex.test(email)
    }

    header: ToolBar {

        height: 45
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            ToolButton {
                icon.source: "qrc:assets/icons/back.svg"
                onClicked: backClicked()
            }

            Label {
                text: "Create Account"
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

        ScrollView {
            id: scrollView
            anchors.fill: parent
            contentWidth: parent.width
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Item {
                width: parent.width
                // Make sure content height is at least as tall as the view
                height: Math.max(contentLayout.height + 40, scrollView.height)

                ColumnLayout {
                    id: contentLayout
                    width: Math.min(parent.width - 40, 600) // Maximum width of 450 pixels
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    spacing: 20

                    // App logo
                    Item {
                        Layout.preferredHeight: 80
                        Layout.fillWidth: true

                        Label {
                            anchors.centerIn: parent
                            text: "🌱 VegFinder"
                            font.pixelSize: 24
                            font.bold: true
                            color: "#4caf50"
                        }
                    }

                    // Register form
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: registerFormLayout.implicitHeight + 40
                        color: "white"
                        radius: 10
                        border.color: "#e0e0e0"

                        ColumnLayout {
                            id: registerFormLayout
                            anchors {
                                fill: parent
                                margins: 20
                            }
                            spacing: 15

                            Label {
                                text: "Join VegFinder"
                                font.pixelSize: 18
                                font.bold: true
                                color: "#424242"
                            }

                            TextField {
                                id: usernameField
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                placeholderText: "Username"
                                selectByMouse: true

                                background: Rectangle {
                                    implicitHeight: 40
                                    color: "#f5f5f5"
                                    border.color: usernameField.activeFocus ? "#4caf50" : "#e0e0e0"
                                    radius: 4
                                }
                            }

                            TextField {
                                id: emailField
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                placeholderText: "Email"
                                selectByMouse: true
                                inputMethodHints: Qt.ImhEmailCharactersOnly


                                background: Rectangle {
                                    implicitHeight: 40
                                    color: "#f5f5f5"
                                    border.color: emailField.activeFocus ? "#4caf50" : "#e0e0e0"
                                    radius: 4
                                }
                            }

                            TextField {
                                id: passwordField
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                placeholderText: "Password"
                                echoMode: TextInput.Password
                                selectByMouse: true

                                background: Rectangle {
                                    implicitHeight: 40
                                    color: "#f5f5f5"
                                    border.color: passwordField.activeFocus ? "#4caf50" : "#e0e0e0"
                                    radius: 4
                                }
                            }

                            TextField {
                                id: confirmPasswordField
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                placeholderText: "Confirm Password"
                                echoMode: TextInput.Password
                                selectByMouse: true

                                background: Rectangle {
                                    implicitHeight: 40
                                    color: "#f5f5f5"
                                    border.color: confirmPasswordField.activeFocus ? "#4caf50" : "#e0e0e0"
                                    radius: 4
                                }
                            }

                            Label {
                                id: passwordMatchError
                                text: "Passwords do not match"
                                color: "#d32f2f"
                                visible: passwordField.text !== confirmPasswordField.text &&
                                         confirmPasswordField.text !== "" &&
                                         passwordField.text !== ""
                            }

                            Button {
                                text: "Create Account"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                enabled: usernameField.text.length > 0 &&
                                         emailField.text.length > 0 &&
                                         passwordField.text.length > 0 &&
                                         passwordField.text === confirmPasswordField.text &&
                                         !userController.loading

                                background: Rectangle {
                                    implicitHeight: 40
                                    color: parent.enabled ? "#4caf50" : "#a5d6a7"
                                    radius: 4
                                }

                                contentItem: Item {
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Create Account"
                                        color: "white"
                                        font.pixelSize: 16
                                        visible: !userController.loading
                                    }

                                    BusyIndicator {
                                        anchors.centerIn: parent
                                        running: userController.loading
                                        width: 24
                                        height: 24
                                    }
                                }

                                onClicked: {
                                    userController.register_(usernameField.text, emailField.text, passwordField.text)
                                }
                            }

                            Label {
                                text: "By registering, you agree to our Terms of Service and Privacy Policy"
                                color: "#9e9e9e"
                                font.pixelSize: 12
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    // Add space at the bottom for better scrolling
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                    }
                }
            }
        }
    }

    // Register success handler
    Connections {
        target: userController

        function onUserDataChanged() {
            if (userController.username !== "" && !userController.isLoggedIn) {
                registerSuccessful()
            }
        }
    }
}
