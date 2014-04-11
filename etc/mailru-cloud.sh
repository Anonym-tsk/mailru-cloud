#!/bin/sh

### BEGIN INIT INFO
# Provides: mailru-cloud
# Required-Start: $local_fs $remote_fs $network $syslog $named
# Required-Stop: $local_fs $remote_fs $network $syslog $named
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# X-Interactive: false
# Short-Description: mailru-cloud service
### END INIT INFO

# Include mailru-cloud defaults if available
test -f /etc/default/mailru-cloud && . /etc/default/mailru-cloud

LOGFILE="cloud.log"
PIDFILE_CL="cloud.pid"
PIDFILE_FB="xvfb.pid"
DISPLAY=99

find_free_servernum() {
    i=${DISPLAY}
    while [ -f /tmp/.X${i}-lock ]; do
        i=$(($i + 1))
    done
    echo ${i}
}

start_xvfb() {
    if [ -f "$HOMEDIR/$DAEMON_DIR/$PIDFILE_FB" ] ; then
        stop_xvfb
    fi
    DISPLAY=$(find_free_servernum)
    start-stop-daemon -b -o -c ${SYSTEM_USER} -S -u ${SYSTEM_USER} -m -p "$HOMEDIR/$DAEMON_DIR/$PIDFILE_FB" -x "/usr/bin/Xvfb" -- ":$DISPLAY" "-extension" "RANDR" "-extension" "GLX" "-screen" "0" "640x480x8" "-nolisten" "tcp"
}

stop_xvfb() {
    start-stop-daemon -o -c ${SYSTEM_USER} -K -u ${SYSTEM_USER} -p "$HOMEDIR/$DAEMON_DIR/$PIDFILE_FB" -R 5
    rm -f "$HOMEDIR/$DAEMON_DIR/$PIDFILE_FB"
}

start() {
    echo "Starting cloud..."
    if [ -f "$HOMEDIR/$DAEMON_DIR/$PIDFILE_CL" ] ; then
        echo "Cloud is already running."
        exit 1
    fi
    if [ -x "$HOMEDIR/$DAEMON_DIR/$DAEMON_BIN" ]; then
        start_xvfb
        rm -f "$HOMEDIR/$DAEMON_DIR/$LOGFILE"
        export DISPLAY=":$DISPLAY"
        start-stop-daemon -b -o -c ${SYSTEM_USER} -S -u ${SYSTEM_USER} -m -p "$HOMEDIR/$DAEMON_DIR/$PIDFILE_CL" -x "$HOMEDIR/$DAEMON_DIR/$DAEMON_BIN" -- "-logfile" "$HOMEDIR/$DAEMON_DIR/$LOGFILE"
        echo "Cloud started succesfully."
    fi
}

stop() {
    echo "Stopping cloud..."
    if [ -x "$HOMEDIR/$DAEMON_DIR/$DAEMON_BIN" ]; then
        start-stop-daemon -o -c ${SYSTEM_USER} -K -u ${SYSTEM_USER} -p "$HOMEDIR/$DAEMON_DIR/$PIDFILE_CL" -R 5
        rm -f "$HOMEDIR/$DAEMON_DIR/$PIDFILE_CL"
        stop_xvfb
        echo "Cloud stopped succesfully."
    fi
}

status() {
    if [ -f "$HOMEDIR/$DAEMON_DIR/$PIDFILE_CL" ] ; then
        echo "Cloud is running."
    else
        echo "Cloud is not running."
    fi
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart|reload|force-reload)
        stop
        start
        ;;
    status)
        status
        ;;
    *)
        echo "Usage: service mailru-cloud {start|stop|reload|force-reload|restart|status}"
        exit 1
esac

exit 0
