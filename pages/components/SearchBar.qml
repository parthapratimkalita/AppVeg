import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: searchBar

    // Properties
    property string searchText: searchField.text

    // Signals
    signal queryChanged(string query)

    color: "white"
    border.color: "#e0e0e0"
    radius: 8

    RowLayout {
        anchors {
            fill: parent
            margins: 10
        }
        spacing: 10

        // Search icon
        Image {
            source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/search.svg"
            sourceSize.width: 24
            sourceSize.height: 24
            Layout.alignment: Qt.AlignVCenter
        }

        // Search field
        TextField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: "Search restaurants..."
            font.pixelSize: 16
            color: "#424242"

            background: Rectangle {
                color: "transparent"
            }

            onTextChanged: {
                queryChanged(text)
            }
        }

        // Clear button
        Image {
            source: "https://cdn.jsdelivr.net/npm/feather-icons/dist/icons/x.svg"
            sourceSize.width: 20
            sourceSize.height: 20
            Layout.alignment: Qt.AlignVCenter
            visible: searchField.text !== ""

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    searchField.text = ""
                    searchField.focus = false
                }
            }
        }
    }
}
