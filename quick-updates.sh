#! /bin/bash

# Each script should define the following variables
# IS_RUNNING should match any process this script can start
# A lock file would usually serve the same purpose, but since
# other scripts could technically be running the same processes
# it's better to just check for those directly
#
IS_RUNNING=$(pgrep -fa "console mautic:(campaigns|import|webhook|reports|maintenance|process|scheduler|cleanup)")
LOGFILE="$(dirname "$0")/logs/mautic_quick_cron.log"

# Common vars and functions
. $(dirname "$0")/common.sh

# Conditionally run mautic scripts
# Verify:
# - Another instance isn't running (see $IS_RUNNING)
# - This is active mautic node (for multi-node installs)
if [ -z "$IS_RUNNING" ]; then
   if [[ $(ip a | grep $MAUTIC_VIP &> /dev/null; echo $?) == 0 ]]; then
      verbose "Did NOT find a currently running script, beginning execution"

      verbose "Running mautic:campaigns:update"
      php $MAUTIC_BASE/bin/console mautic:campaigns:update $MAUTIC_OPTS $CAMPAIGNS_BATCH_LIMIT >> $LOGFILE

      verbose "Running mautic:campaigns:trigger"
      php $MAUTIC_BASE/bin/console mautic:campaigns:trigger $MAUTIC_OPTS $CAMPAIGNS_BATCH_LIMIT >> $LOGFILE

      verbose "Running mautic:import"
      php $MAUTIC_BASE/bin/console mautic:import $MAUTIC_OPTS >> $LOGFILE

      verbose "Running mautic:webhooks:process"
      php $MAUTIC_BASE/bin/console mautic:webhooks:process $MAUTIC_OPTS >> $LOGFILE

      verbose "Running mautic:reports:scheduler"
      php $MAUTIC_BASE/bin/console mautic:reports:scheduler $MAUTIC_OPTS >> $LOGFILE

      verbose "Running mautic:maintenance:cleanup"
      php $MAUTIC_BASE/bin/console mautic:maintenance:cleanup $MAUTIC_OPTS $CLEANUP_DAYS --dry-run >> $LOGFILE
      php $MAUTIC_BASE/bin/console mautic:maintenance:cleanup $MAUTIC_OPTS $CLEANUP_DAYS >> $LOGFILE
   fi
else
   verbose "Quick updates cron script is already running - exiting"
fi
