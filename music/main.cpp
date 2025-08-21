#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTextCodec>
#include "systemuicommonapiclient.h"
#include <QQmlContext>
#include <QDir>
#include "lyricmodel.h"
#include "playlistmodel.h"
#include "imageanalyzer.h"
#include "audiospectrumanalyzer.h"
#include <QQmlEngine>
#include <QTranslator>
#include "languagemanager.h"
int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8"));
    qunsetenv("USE_PLAYBIN3");
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    LanguageManager languageManager(&engine, app.applicationName());
    engine.rootContext()->setContextProperty("languageManager", &languageManager);
    qmlRegisterType<SystemUICommonApiClient>("com.alientek.qmlcomponents", 1, 0, "SystemUICommonApiClient");
    engine.rootContext()->setContextProperty("appCurrtentDir", QCoreApplication::applicationDirPath());
    qmlRegisterType<lyricModel>("com.alientek.qmlcomponents", 1, 0, "LyricModel");
    qmlRegisterType<playListModel>("com.alientek.qmlcomponents", 1, 0, "PlayListModel");
    qmlRegisterType<ImageAnalyzer>("com.alientek.qmlcomponents", 1, 0, "ImageAnalyzer");
    qmlRegisterType<AudioSpectrumAnalyzer>("com.alientek.qmlcomponents", 1, 0, "AudioSpectrumAnalyzer");

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    QObject *root = engine.rootObjects().first();
    QObject *qmlAudio = root->findChild<QObject *>("myAudio");
    QMediaPlayer *player = qvariant_cast<QMediaPlayer *>(qmlAudio->property("mediaObject"));

    engine.rootContext()->setContextProperty("myplayer", player);

    return app.exec();
}
