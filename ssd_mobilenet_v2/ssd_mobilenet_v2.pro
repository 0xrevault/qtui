QT += quick multimedia core

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

CONFIG += c++17

SOURCES += \
        drawmarksitem.cpp \
        include/mark.cpp \
        include/ssdmobilenetpp.cpp \
        include/staimpuwrapper.cpp \
        main.cpp \
        nnthread.cpp

RESOURCES += qml.qrc \
    res.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/ui/src/apps
!isEmpty(target.path): INSTALLS += target

include(../client/client.pri)
include(../mediaengine/mediaengine.pri)
INCLUDEPATH += ../client
INCLUDEPATH += ./include
INCLUDEPATH += ../mediaengine

HEADERS += \
    drawmarksitem.h \
    include/mark.h \
    include/ssdmobilenetpp.h \
    include/staimpuwrapper.h \
    nnthread.h

 CONFIG += link_pkgconfig
 PKGCONFIG += stai_mpu
