#! /bin/bash

# Each script should define the following variables
# IS_RUNNING should match any process this script can start
# A lock file would usually serve the same purpose, but ttpearso
# wasn't sure that would catch all cases since technically these
# are just Mautic commands that other scripts could start
#
IS_RUNNING=$(pgrep -fa "console mautic:(segment)")
LOGFILE="$(dirname "$0")/logs/mautic_segment_cron.log"

# Common vars and functions
. $(dirname "$0")/common.sh

# Conditionally run mautic scripts
# Verify:
# - Another instance isn't running (see $IS_RUNNING)
# - This is active mautic node (for multi-node installs)
if [ -z "$IS_RUNNING" ]; then
   if [[ $(ip a | grep $MAUTIC_VIP &> /dev/null; echo $?) == 0 ]]; then
      verbose "Did NOT find a currently running script, beginning execution"
      verbose "Running mautic:segment:update"
      php $MAUTIC_BASE/bin/console mautic:segment:update $MAUTIC_OPTS $SEGMENT_BATCH_LIMIT >> $LOGFILE
   fi
else
   verbose "Segments script is already running - exiting"
fi

