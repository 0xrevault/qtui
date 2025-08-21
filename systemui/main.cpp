#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTextCodec>
#include <QQmlContext>
#include <QDebug>
#include <QFile>
#include <QLocale>
#include "apklistmodel.h"
#include "systemuicommonapiserver.h"
#include "launchintent.h"
#include "instructionsfileread.h"
#include "memorywatcher.h"

#include <QTranslator>
#include "languagemanager.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);
    QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8"));

    QLocale locale(QLocale::Chinese);
    QLocale::setDefault(locale);

    /*QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();

    for (const QString &locale : uiLanguages) {
        const QString baseName = app.applicationName() + "_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName)) {
            app.installTranslator(&translator);
            break;
        }
    }*/

    QString hostName;
    QFile file("/etc/hostname");
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        hostName =  file.readLine().simplified();
        file.close();
        if (hostName == "ATK-DLMP257") {
            system("echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor");
            system("echo 1500000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed");
        }
    }

    QQmlApplicationEngine engine;
    LanguageManager languageManager(&engine, app.applicationName());
    engine.rootContext()->setContextProperty("languageManager", &languageManager);
    engine.rootContext()->setContextProperty("appCurrtentDir", QCoreApplication::applicationDirPath());
    engine.rootContext()->setContextProperty("hostName", hostName);
    qmlRegisterType<ApkListModel>("com.alientek.qmlcomponents", 1, 0, "ApkListModel");
    qmlRegisterType<SystemUICommonApiServer>("com.alientek.qmlcomponents", 1, 0, "SystemUICommonApiServer");
    qmlRegisterType<InstructionsFileRead>("com.alientek.qmlcomponents", 1, 0, "InstructionsFileRead");
    qmlRegisterType<MemoryWatcher>("com.alientek.qmlcomponents", 1, 0, "MemoryWatcher");
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
