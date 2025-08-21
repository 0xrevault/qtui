QT += quick

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        apklistmodel.cpp \
        instructionsfileread.cpp \
        main.cpp \
        memorywatcher.cpp

RESOURCES += qml.qrc

# TRANSLATIONS += \
#     $${TARGET}_zh_CN.ts \
#     $${TARGET}_en_US.ts

# CONFIG += lupdate lrelease
# CONFIG += embed_translations
 # lupdate linguist
# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/ui
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    apklistmodel.h \
    instructionsfileread.h \
    memorywatcher.h

include(../server/server.pri)
INCLUDEPATH += ../server \
                ../common

