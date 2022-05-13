#! /bin/bash

# Per environment setting - we run a pair of servers for our Mautic
# but we only want to run crons on a single server since it operates on the same data

### Production settings

# Typically, this is the user your web server runs as
# Debian/Ubuntu and probably many others, will use 'www-data' by default
MAUTIC_USER="www-data"

# This refers to the internal IP address your Mautic server has, we use this to verify
# we're running only on a single server, but able to deploy them to as many mautic servers
# as we please
MAUTIC_VIP="172.16.0.5"

# Location of your Mautic install
MAUTIC_BASE="/srv/www/mautic"
 
### Dev settings

#MAUTIC_VIP="172.20.0.5"
#MAUTIC_BASE="/srv/www/mautic-dev"


# TODO: Should probably be using this to confirm user, but needs
# testing to confirm it works under cron users
# 
#if [ "$(whoami)" != "$MAUTIC_USER" ]; then
#   verbose "Script must be run as user: $MAUTIC_USER"
#   exit 255
#fi

# Informs mautic scripts we're running in non-interactive modes, skip prompts
MAUTIC_OPTS="--no-interaction --no-ansi"

# These are largely "best guesses", or defaults
# Refer to Mautic documentation for more information
CAMPAIGNS_BATCH_LIMIT="--batch-limit=300"
SEGMENT_BATCH_LIMIT="--batch-limit=300"
CLEANUP_DAYS="--days-old=35"
EMAIL_MSG_LIMIT="--message-limit=1000"
MAX_CONTACTS="--max-contacts=300"
BROADCAST_LIMIT="--limit=500"

function verbose() {
   TS=$(date -Is)
   echo -e "\n$TS - $@" >> $LOGFILE
}

if [ ! -e "$LOGFILE" ]; then
   touch $LOGFILE
fi

if [ ! -w "$LOGFILE" ]; then
   echo "Logfile $LOGFILE doesn't exist, or isn't writable by the user running this script"
   exit 255
fi

if [ ! -h "/etc/logrotate.d/mautic-scripts-log-rotation.conf" ]; then
   verbose "WARNING - Log rotation is NOT enabled, logs can grow very large, see README.md for more information"
fi
