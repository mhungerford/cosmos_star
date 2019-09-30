#include <QGuiApplication>
#include <QQmlApplicationEngine>

#ifdef Q_OS_ANDROID
#include <QtAndroidExtras/QtAndroid>
#endif


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

// Lock screen rotation to portrait
#ifdef Q_OS_ANDROID
    QAndroidJniObject activity = QtAndroid::androidActivity();
    activity.callMethod<void>("setRequestedOrientation", "(I)V", 1);
#endif


    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
