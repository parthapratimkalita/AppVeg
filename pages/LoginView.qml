import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: loginPage

    // Signals
    signal backClicked()
    signal loginSuccessful()
    signal registerRequested()

    header: ToolBar {
        height: 45

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 8

            ToolButton {
                icon.source: "qrc:assets/icons/back.svg"
                onClicked: backClicked()
            }

            Label {
                text: "Login"
                font.pixelSize: 20
                font.bold: true
                elide: Label.ElideRight
                Layout.fillWidth: true
            }
        }
    }

    background: Rectangle {
        color: "#f5f5f5"
    }

    Flickable {
        anchors.fill: parent
        contentHeight: mainContent.height
        clip: true

        Item {
            id: mainContent
            width: Math.min(parent.width - 40, 600)  // Responsive max width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 40

            ColumnLayout {
                id: mainColumn
                width: parent.width
                spacing: 24

                // Logo area
                Item {
                    Layout.preferredHeight: 100
                    Layout.fillWidth: true

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Image {
                            source: "qrc:/images/vegfinder-logo.png"
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            fillMode: Image.PreserveAspectFit

                            Text {
                                visible: parent.status !== Image.Ready
                                anchors.centerIn: parent
                                text: "🌱"
                                font.pixelSize: 24
                            }
                        }

                        Label {
                            text: "VegFinder"
                            font.pixelSize: 24
                            font.bold: true
                            color: "#4caf50"
                        }
                    }
                }

                // Login form card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: loginForm.implicitHeight + 40
                    color: "white"
                    radius: 10
                    border.color: "#e0e0e0"

                    ColumnLayout {
                        id: loginForm
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 16

                        Label {
                            text: "Welcome Back"
                            font.pixelSize: 18
                            font.bold: true
                            color: "#424242"
                            Layout.bottomMargin: 4
                        }

                        TextField {
                            id: usernameField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            placeholderText: "Username"
                            selectByMouse: true
                            leftPadding: 12

                            background: Rectangle {
                                implicitHeight: 48
                                color: "#f5f5f5"
                                border.color: usernameField.activeFocus ? "#4caf50" : "#e0e0e0"
                                border.width: usernameField.activeFocus ? 2 : 1
                                radius: 4
                            }
                        }

                        TextField {
                            id: passwordField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            Layout.topMargin: 8
                            placeholderText: "Password"
                            echoMode: TextInput.Password
                            selectByMouse: true
                            leftPadding: 12

                            background: Rectangle {
                                implicitHeight: 48
                                color: "#f5f5f5"
                                border.color: passwordField.activeFocus ? "#4caf50" : "#e0e0e0"
                                border.width: passwordField.activeFocus ? 2 : 1
                                radius: 4
                            }
                        }

                        Button {
                            id: loginButton
                            text: "Log In"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            Layout.topMargin: 16
                            enabled: usernameField.text.length > 0 &&
                                     passwordField.text.length > 0 &&
                                     !userController.loading

                            background: Rectangle {
                                implicitHeight: 48
                                color: loginButton.enabled ?
                                      (loginButton.pressed ? "#388e3c" : "#4caf50") :
                                      "#a5d6a7"
                                radius: 4

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }

                            contentItem: Item {
                                Text {
                                    anchors.centerIn: parent
                                    text: "Log In"
                                    color: "white"
                                    font.pixelSize: 16
                                    font.bold: true
                                    visible: !userController.loading
                                }
                            }

                            onClicked: {
                                userController.login(usernameField.text, passwordField.text)
                            }
                        }
                    }
                }

                // Register link
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 24
                    spacing: 5

                    Label {
                        text: "Don't have an account?"
                        color: "#616161"
                    }

                    Label {
                        id: registerLink
                        text: "Register"
                        color: "#4caf50"
                        font.bold: true

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.width: registerArea.containsMouse ? 1 : 0
                            border.color: "#4caf50"
                            radius: 2
                            visible: registerArea.containsMouse
                        }

                        MouseArea {
                            id: registerArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: registerRequested()
                        }
                    }
                }

                // Spacer at the bottom
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 20
                }
            }
        }
    }

    Connections {
        target: userController

        function onAuthStateChanged() {
            if (userController.isLoggedIn) {
                loginSuccessful()
            }
        }

        function onLoginError(errorMessage) {
            errorDialog.text = errorMessage
            errorDialog.open()
        }
    }

    Dialog {
        id: errorDialog
        title: "Login Error"
        standardButtons: Dialog.Ok
        property string text: ""

        contentItem: Label {
            text: errorDialog.text
            wrapMode: Label.Wrap
        }

        anchors.centerIn: Overlay.overlay
        width: Math.min(loginPage.width - 50, 400)
    }
}
