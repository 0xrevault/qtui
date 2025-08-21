RESOURCES += \
    $$PWD/common.qrc

HEADERS += \
    $$PWD/languagemanager.h

SOURCES += \
    $$PWD/languagemanager.cpp

TRANSLATIONS += \
    $${TARGET}_zh_CN.ts \
    $${TARGET}_en_US.ts

!equals(TARGET, "template") {
    CONFIG += lupdate lrelease
    CONFIG += embed_translations
}

