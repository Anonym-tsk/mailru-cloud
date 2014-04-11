#!/bin/sh

. etc/init
echo "Installing Mail.ru Cloud..."; echo

EMAIL=""
PASSWORD=""

# Linux client url
URL="https://desktopcloud.cdnmail.ru/linux/i386/cloud"
if [ `getconf LONG_BIT` = "64" ] ; then
    URL="https://desktopcloud.cdnmail.ru/linux/amd64/cloud"
fi

# Read email
while [ -z "$EMAIL" ]; do
    read -p "Email: " EMAIL
done

# Read password
stty -echo
while [ -z "$PASSWORD" ]; do
    read -p "Password: " PASSWORD; echo
done
stty echo

# Create daemon and cloud directories
mkdir -p "$HOMEDIR/$CLOUD_DIR"
mkdir -p "$HOMEDIR/$DAEMON_DIR"

# Download cloud client
if [ ! -x "$HOMEDIR/$DAEMON_DIR/$DAEMON_BIN" ]; then
    rm -f "$HOMEDIR/$DAEMON_DIR/$DAEMON_BIN"
    wget -O "$HOMEDIR/$DAEMON_DIR/$DAEMON_BIN" "$URL"
    chmod +x "$HOMEDIR/$DAEMON_DIR/$DAEMON_BIN"
fi

# Create default config
echo "validfinish=0\nemail=$EMAIL\nfolder=$HOMEDIR/$CLOUD_DIR\n" > "$HOMEDIR/.Mail.Ru_Cloud"

# First run for create default params
start-stop-daemon -b -o -c ${SYSTEM_USER} -S -u ${SYSTEM_USER} -x "/usr/bin/Xvfb" -- ":43" "-extension" "RANDR" "-extension" "GLX" "-screen" "0" "640x480x8" "-nolisten" "tcp"
sleep 1
export DISPLAY=":43"
start-stop-daemon -b -o -c ${SYSTEM_USER} -S -u ${SYSTEM_USER} -x "$HOMEDIR/$DAEMON_DIR/$DAEMON_BIN" -- "-email" "$EMAIL" "-password" "$PASSWORD" "-acceptLicense" "1" "-folder" "$HOMEDIR/$CLOUD_DIR"
sleep 1
start-stop-daemon -o -c ${SYSTEM_USER} -K -u ${SYSTEM_USER} -x "$HOMEDIR/$DAEMON_DIR/$DAEMON_BIN"
sleep 1
start-stop-daemon -o -c ${SYSTEM_USER} -K -u ${SYSTEM_USER} -x "/usr/bin/Xvfb"

# Create init script and service
sudo cp "etc/mailru-cloud.sh" "/etc/init.d/mailru-cloud"
sudo chmod 755 "/etc/init.d/mailru-cloud"
sudo bash -c "echo -e \"SYSTEM_USER=$SYSTEM_USER\nHOMEDIR=$HOMEDIR\nDAEMON_DIR=$DAEMON_DIR\nDAEMON_BIN=$DAEMON_BIN\n\" > /etc/default/mailru-cloud"
sudo update-rc.d mailru-cloud defaults

echo "Mail.ru Cloud installed succesfully."; echo
exit 0
