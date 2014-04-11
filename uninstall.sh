#!/bin/sh

. etc/init
echo "Uninstalling Mail.ru Cloud..."; echo

# Stop service
sudo service mailru-cloud stop

# Remove init script and service
sudo update-rc.d -f mailru-cloud remove
sudo rm -f "/etc/default/mailru-cloud"
sudo rm -f "/etc/init.d/mailru-cloud"

# Remove config
rm -f ${HOMEDIR}/.Mail.Ru_Cloud*

# Remove daemon and cloud directories
#rm -rf "$HOMEDIR/$CLOUD_DIR"
rm -rf "$HOMEDIR/$DAEMON_DIR"

echo "Mail.ru Cloud uninstalled succesfully."; echo
exit 0
