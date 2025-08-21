#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTextCodec>
#include "systemuicommonapiclient.h"
#include "camera.h"
#include "videooutput.h"
#include "drawmarksitem.h"
#include "nnthread.h"
#include <QTranslator>
#include "languagemanager.h"
int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    qunsetenv("USE_PLAYBIN3");
    QGuiApplication app(argc, argv);

    qRegisterMetaType<Marks>("Marks");

    qmlRegisterType<SystemUICommonApiClient>("com.alientek.qmlcomponents", 1, 0, "SystemUICommonApiClient");
    qmlRegisterType<Camera>("com.alientek.qmlcomponents", 1, 0, "Camera");
    qmlRegisterType<VideoOutput>("com.alientek.qmlcomponents", 1, 0, "VideoOutput");
    qmlRegisterType<DrawMarksItem>("com.alientek.qmlcomponents", 1, 0, "DrawMarksItem");
    qmlRegisterType<NnThread>("com.alientek.qmlcomponents", 1, 0, "NnThread");
    QQmlApplicationEngine engine;
    LanguageManager languageManager(&engine, app.applicationName());
    engine.rootContext()->setContextProperty("languageManager", &languageManager);
    engine.rootContext()->setContextProperty("appCurrtentDir", QCoreApplication::applicationDirPath());
    QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8"));
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
