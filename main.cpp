#include "processengine.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:///");

    ProcessEngine processEngine;
    engine.rootContext()->setContextProperty("processEngine", &processEngine);
    qmlRegisterUncreatableType<Process>("CouchPotato", 1, 0, "Process", "Can't create process from QML");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
