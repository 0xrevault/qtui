/******************************************************************
Copyright © Deng Zhimao Co., Ltd. 2021-2030. All rights reserved.
* @projectName   key
* @brief         keyinputeventthread.cpp
* @author        Deng Zhimao
* @email         dengzhimao@alientek.com/1252699831@qq.com
* @link          www.openedv.com
* @date          2024-11-27
*******************************************************************/
#include "keyinputeventthread.h"
#include <QKeyEvent>

KeyInputEventThread::KeyInputEventThread(QObject *parent)
    : QThread{parent}
{
    this->start();
}

KeyInputEventThread::~KeyInputEventThread()
{
    system("killall key");
}

int KeyInputEventThread::ev_init()
{
    DIR *dir;
    struct dirent *de;
    int fd;
    char name[80];
    dir = opendir("/dev/input");
    if(dir != 0) {
        while((de = readdir(dir))) {
            if(strncmp(de->d_name, "event", 5))
                continue;
            fd = openat(dirfd(dir), de->d_name, O_RDONLY);
            if(fd < 0) continue;
            else {
                if (ioctl(fd, EVIOCGNAME(sizeof(name) - 1), &name) < 1) {
                    name[0] = '\0';
                }
                if (strcmp(name, "gpio-keys")) {
                    close(fd);
                    continue;
                }
            }
            ev_fds[ev_count].fd = fd;
            ev_fds[ev_count].events = POLLIN;
            evs[ev_count].fd = &ev_fds[ev_count];

            ev_count++;
            if(ev_count == MAX_DEVICES) break;
            break;
        }
    }

    return 0;
}

int KeyInputEventThread::ev_get(input_event *ev, unsigned dont_wait)
{
    int r;
    unsigned n;

    do {
        r = poll(ev_fds, ev_count, dont_wait ? 0 : -1);

        if(r > 0) {
            for(n = 0; n < ev_count; n++) {
                if(ev_fds[n].revents & POLLIN) {
                    r = read(ev_fds[n].fd, ev, sizeof(*ev));
                    if(r == sizeof(*ev)) {
                        //if (!vk_modify(&evs[n], ev))
                        return 0;
                    }
                }
            }
        }
    } while(dont_wait == 0);

    return -1;
}

void KeyInputEventThread::run()
{
    struct input_event ev;

    if (ev_init() != 0)
        goto err_out;

    for ( ; ; ) {
        if (ev_get(&ev, 0) == 0) {
            if (EV_KEY == ev.type) {
                if (ev.value == 0) {
                    switch(ev.code) {
                    case BTN_1:
                        emit keyEvent(Qt::Key_1, false);
                        break;
                    }
                } else if (ev.value == 1) {
                    switch(ev.code) {
                    case BTN_1:
                        emit keyEvent(Qt::Key_1, true);
                        break;
                    }
                }
            }
        }
    }

err_out:
    qDebug("no keys ！！");
}
