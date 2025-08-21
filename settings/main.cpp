#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "systemuicommonapiclient.h"
#include "wifiservicessettings.h"
#include <QFile>
#include <QDir>
#include "systemcontrol.h"
#include <QTranslator>
#include "languagemanager.h"
int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
#if 0
    QDir dir("/etc/connman");
    if (!dir.exists())
        dir.mkdir("/etc/connman");
    QFile file("/etc/connman/main.conf");
    if (!file .exists()) {
        if (file.open(QIODevice::ReadWrite)) {
            QString conf = "[General]\nNetworkInterfaceBlacklist = wlan0\n";
            file.write(conf.toUtf8());
            file.close();
        }
    } else {
        if (file.open(QIODevice::ReadWrite)) {
            QString content = file.readAll();
            if (!content.contains("wlan0")) {
                QStringList strList = content.split("=");
                if (strList.length() == 2) {
                    file.resize(0);
                    QString conf = "[General]\nNetworkInterfaceBlacklist = "  + strList[1].simplified() + ",wlan0";
                    file.write(conf.toUtf8());
                }
            }
            file.close();
        }
    }
    system("rfkill unblock 1");
    //system("rm -rf ethernet_*");
    system("systemctl start connman");
#endif
    system("rfkill unblock all");
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
    QGuiApplication app(argc, argv);
    qmlRegisterType<SystemUICommonApiClient>("com.alientek.qmlcomponents", 1, 0, "SystemUICommonApiClient");
    qmlRegisterType<WifiServicesSettings>("com.alientek.qmlcomponents", 1, 0, "WifiServicesSettings");
    qmlRegisterType<SystemControl>("com.alientek.qmlcomponents", 1, 0, "SystemControl");
    QQmlApplicationEngine engine;
    LanguageManager languageManager(&engine, app.applicationName());
    engine.rootContext()->setContextProperty("languageManager", &languageManager);
    engine.addImportPath(":/CustomStyle");
    qputenv("QT_VIRTUALKEYBOARD_STYLE", "greywhite");
    engine.rootContext()->setContextProperty("appCurrtentDir", QCoreApplication::applicationDirPath());
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

    return app.exec();
}
