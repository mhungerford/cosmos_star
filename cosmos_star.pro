QT = core gui quick
CONFIG += c++17
CONFIG += release

SOURCES += main.cpp

RESOURCES += qml.qrc

DEFINES += QT_DEPRECATED_WARNINGS
#DEFINES -= QT_NETWORK_LIB QT_CORE_LIB

wasm:QMAKE_LFLAGS += -s ALLOW_MEMORY_GROWTH=0 -s TOTAL_MEMORY=128Mb -s DISABLE_EXCEPTION_CATCHING=1

#try to make binary smaller
CONFIG += ltcg
CONFIG += optimize_full
CONFIG += release
QT_PLUGINS -= qgif qwebp qtiff qico qsvg qtga qicns qjpeg qwbmp

#if platform is android, add extra dependencies
android: QT += androidextras

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_PACKAGE_SOURCE_DIR = \
        $$PWD/android
}

