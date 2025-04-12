#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <QLocale>
#include <QTranslator>
#include <QQuickWindow>

#include "UserController.h"
#include "ResturantModel.h"
#include "AppController.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "AppVeg_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName)) {
            app.installTranslator(&translator);
            break;
        }
    }

    // Instantiate your C++ controller classes
    UserController userController;
    RestaurantModel restaurantModel;
    AppController appController;

    // Set context properties so QML can access them
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("userController", &userController);
    engine.rootContext()->setContextProperty("restaurantModel", &restaurantModel);
    engine.rootContext()->setContextProperty("appController", &appController);


    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    // 🔽 Set minimum window size after loading the QML
    const QList<QObject *> roots = engine.rootObjects();
    if (!roots.isEmpty()) {
        QObject *topLevel = roots.first();
        QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);
        if (window) {
            window->setMinimumWidth(400);
            window->setMinimumHeight(600);
        }
    }

    return app.exec();
}
