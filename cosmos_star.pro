QT = core gui quick
CONFIG += c++17
CONFIG += release

SOURCES += main.cpp

RESOURCES += qml.qrc

DEFINES += QT_DEPRECATED_WARNINGS
#DEFINES -= QT_NETWORK_LIB QT_CORE_LIB

# Set total memory lower for Android/IPhone support (default 1GB pre-allocated)
wasm:QMAKE_WASM_TOTAL_MEMORY = 256MB
wasm:QMAKE_LFLAGS += -s ALLOW_MEMORY_GROWTH=0 -s DISABLE_EXCEPTION_CATCHING=1
# wasm:QMAKE_LFLAGS += -s NO_FILESYSTEM=1 -s FILESYSTEM=0 
# Single file embeds wasm as base64 into js (-s SINGLE_FILE=1)
#wasm:QMAKE_LFLAGS += -s SINGLE_FILE=1
#wasm:QMAKE_LFLAGS += --llvm-lto 1
#wasm:QMAKE_LFLAGS += --target=wasm32
wasm:LIBS += -lidbfs.js
#wasm:WASM_OBJECT_FILES=1
wasm:equals(WASM_OBJECT_FILES, 1) {
   message("WASM_OBJECT_FILES:" $$WASM_OBJECT_FILES " Enabled")
   #remove unsupported options when using WASM_OBJECT_FILES support
   QMAKE_LFLAGS -= -s WASM=1 -s FULL_ES2=1 -s USE_WEBGL2=1 -s NO_EXIT_RUNTIME=0 -s ERROR_ON_UNDEFINED_SYMBOLS=1 -s ALLOW_MEMORY_GROWTH=0 -s DISABLE_EXCEPTION_CATCHING=1
   # when using WASM_OBJECT_FILES, this dependency is missed (index db file-system support)
   LIBS += -lidbfs.js
}

#try to make binary smaller
CONFIG += ltcg
CONFIG += optimize_full
CONFIG += release
QT_PLUGINS -= qgif qwebp qtiff qico qsvg qtga qicns qjpeg qwbmp

#if platform is android, add extra dependencies
android: QT += androidextras

# Additional import path used to resolve QML modules in Qt Creators code model
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

# Google Play workaround for version code difference for 32-bit and 64-bit
defineReplace(droidVersionCode) {
        segments = $$split(1, ".")
        for (segment, segments): vCode = "$$first(vCode)$$format_number($$segment, width=3 zeropad)"
        contains(ANDROID_TARGET_ARCH, arm64-v8a): suffix = 1
        else:contains(ANDROID_TARGET_ARCH, armeabi-v7a): suffix = 0
        # add more cases as needed
        return($$first(vCode)$$first(suffix))
}

VERSION = 1.2.3
ANDROID_VERSION_NAME = $$VERSION
ANDROID_VERSION_CODE = $$droidVersionCode($$ANDROID_VERSION_NAME)

