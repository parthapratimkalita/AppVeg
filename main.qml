import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "pages"
import "pages/components"



ApplicationWindow {
    id: window
    visible: true
    width: 360
    height: 640
    title: "AppVeg"

    // Global properties
    property bool isWideScreen: width > 600
    property string currentRestaurantId: ""
    property bool isLoggedIn: userController.isLoggedIn

    // Initial component setup

    Component.onCompleted: {
        console.log("Is logged in:", userController.isLoggedIn)
        appController.initialize()

        if (userController.isLoggedIn) {
            console.log("Loading home page")
            userController.getFavorites()
            stackView.push(homeComponent)
        } else {
            console.log("Loading login page")
            stackView.push(loginComponent)
            //stackView.push(homeComponent)
        }
    }

    // Connect to auth state changes
    Connections {
        target: userController
        function onAuthStateChanged() {
            console.log("Auth state changed, isLoggedIn:", userController.isLoggedIn)
            if (userController.isLoggedIn) {
                // If we're not already on the home page, navigate there
                if (stackView.currentItem !== homeComponent) {
                    stackView.push(homeComponent)
                }
                userController.getFavorites()
            }
        }
    }

    // Connect to favorite signals
    Connections {
        target: userController
        function onFavoritesUpdated(favoriteIds) {
            // Update restaurant model with favorite status
            for (var i = 0; i < favoriteIds.length; i++) {
                restaurantModel.setFavoriteStatus(favoriteIds[i], true)
            }
        }

        function onFavoriteAdded(restaurantId) {
            restaurantModel.setFavoriteStatus(restaurantId, true)
        }

        function onFavoriteRemoved(restaurantId) {
            restaurantModel.setFavoriteStatus(restaurantId, false)
        }
    }

    // Connect to restaurant model favorite toggle
    Connections {
        target: restaurantModel
        function onFavoriteToggled(id, isFavorite) {
            if (isLoggedIn) {
                if (isFavorite) {
                    userController.addToFavorites(id)
                } else {
                    userController.removeFromFavorites(id)
                }
            } else {
                // If not logged in, revert the toggle and show login prompt
                restaurantModel.setFavoriteStatus(id, false)
                loginPromptDialog.open()
            }
        }
    }

    // App state
    StackView {
        id: stackView
        anchors.fill: parent
        //initialItem: homeComponent
    }


    // Home component
    Component {
        id: homeComponent
        HomeView {
            onOpenRestaurantList: stackView.push(restaurantListComponent)
            onOpenMap: stackView.push(mapComponent)
            onOpenLogin: stackView.push(loginComponent)
            onOpenProfile: stackView.push(profileComponent)
            onOpenFavorites: stackView.push(favoritesComponent)
        }
    }

    // Restaurant list component
    Component {
        id: restaurantListComponent
        RestaurantListView {
            onBackClicked: stackView.pop()
            onRestaurantSelected: {
                currentRestaurantId = restaurantId
                stackView.push(restaurantDetailComponent)
            }
        }
    }

    // Restaurant detail component
    Component {
        id: restaurantDetailComponent
        RestaurantDetail {
            restaurantId: currentRestaurantId
            onBackClicked: stackView.pop()
            onShowOnMap: {
                stackView.pop()
                stackView.push(mapComponent, { focusRestaurantId: currentRestaurantId })
            }
        }
    }

    // Map component
    Component {
        id: mapComponent
        MapView {
            onBackClicked: stackView.pop()
            onRestaurantSelected: {
                currentRestaurantId = restaurantId
                stackView.push(restaurantDetailComponent)
            }
        }
    }

    // Login component
    Component {
        id: loginComponent
        LoginView {
            onBackClicked: stackView.pop()
            onLoginSuccessful: {
                stackView.pop()  // Remove login page
                stackView.push(homeComponent)  // Add home page
                userController.getFavorites()  // Get favorites after navigation
            }
            onRegisterRequested: stackView.push(registerComponent)
        }
    }

    // Register component
    Component {
        id: registerComponent
        RegisterView {
            onBackClicked: stackView.pop()
            onRegisterSuccessful: {
                stackView.pop()
                stackView.pop()
            }
        }
    }

    // Profile component
    Component {
        id: profileComponent
        ProfileView {
            onBackClicked: stackView.pop()
            onLogoutSuccessful: {
                stackView.pop()
                // Return to home and reset stack
                while (stackView.depth > 1) {
                    stackView.pop()
                }
            }
        }
    }

    // Favorites component
    Component {
        id: favoritesComponent
        FavoritesView {
            onBackClicked: stackView.pop()
            onRestaurantSelected: {
                currentRestaurantId = restaurantId
                stackView.push(restaurantDetailComponent)
            }
        }
    }

    // Login prompt dialog
    Dialog {
        id: loginPromptDialog
        title: "Login Required"
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        anchors.centerIn: Overlay.overlay

        onAccepted: stackView.push(loginComponent)

        Label {
            text: "You need to be logged in to save favorites."
            wrapMode: Text.WordWrap
            width: parent.width
        }
    }

    // Error notification
    Popup {
        id: errorPopup
        width: parent.width * 0.8
        height: errorText.height + 40
        x: (parent.width - width) / 2
        y: 20
        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#d32f2f"
            radius: 5
        }

        Text {
            id: errorText
            text: appController.error
            color: "white"
            anchors.centerIn: parent
            width: parent.width - 20
            wrapMode: Text.WordWrap
        }

        Timer {
            id: errorTimer
            interval: 5000
            onTriggered: {
                errorPopup.close()
                appController.clearError()
            }
        }

        onAboutToShow: errorTimer.start()
    }

    // Show error popup when error occurs
    Connections {
        target: appController

        function onErrorChanged() {
            if (appController.error !== "") {
                errorPopup.open()
            }
        }
    }

    // User controller error handler
    Connections {
        target: userController

        function onErrorMessageChanged() {
            if (userController.errorMessage !== "") {
                errorText.text = userController.errorMessage
                errorPopup.open()
            }
        }
    }
}
