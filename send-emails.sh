#! /bin/bash

# Each script should define the following variables
# IS_RUNNING should match any process this script can start
# A lock file would usually serve the same purpose, but ttpearso
# wasn't sure that would catch all cases since technically these
# are just Mautic commands that other scripts could start
IS_RUNNING=$(pgrep -fa "mautic:(broadcasts:send|emails:send)")
LOGFILE="$(dirname "$0")/logs/mautic_email_cron.log"

# Common vars and functions
. $(dirname "$0")/common.sh

# Conditionally run mautic scripts
# Verify:
# - Another instance isn't running
# - This is active mautic node (for multi-node installs, eg: prod)
if [ -z "$IS_RUNNING" ]; then
   if [[ $(ip a | grep $MAUTIC_VIP &> /dev/null; echo $?) == 0 ]]; then
      verbose "Did NOT find a script sending emails, beginning execution"

      verbose "Running mautic:broadcast:send"
      php $MAUTIC_BASE/bin/console mautic:broadcasts:send $BROADCAST_LIMIT >> $LOGFILE

      verbose "Running mautic:emails:send"
      php $MAUTIC_BASE/bin/console mautic:emails:send $EMAIL_MSG_LIMIT >> $LOGFILE
   fi
else
   verbose "Email script is already running - exiting"
fi

