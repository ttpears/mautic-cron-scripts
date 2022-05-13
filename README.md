# mautic-cron-scripts

These scripts are attempted improvements to run [Mautic's suggested crons](https://docs.mautic.org/en/setup/cron-jobs).  
The company I work for uses Mautic, but we have some large segments that take a considerable amount of time to update.  
We've optimized/trimmed the database as much we can, and given it quite nice hardware, but still takes 4+ hours on average.  

These ensure a few things:
+ We're _always_ running segment updates
+ No need to guestimate how often each cron process should run
+ Emails can consistently be processed out
+ Easier to maintain when running multiple Mautic servers/installs
+ Logging makes it clear _what exactly_ is running, and when

The Mautic Community was very helpful in trying to help us when I started this optimization project.  
Our "full segment updates" were taking 30+ hours, so a big thank you to [everyone on this thread](https://forum.mautic.org/t/always-long-running-queries-against-email-stats-5-hours/23898), and the Mautic Community in general, hopefully others can find some use for these scripts.

## Getting started

### common.sh

#### Make sure to review and update `common.sh` accordingly.

+ `MAUTIC_USER` - What user Mautic runs as, often the same as your webserver user
+ `MAUTIC_VIP` - The IP address your primary Mautic install runs on.  This allows for the crons to deployed to multiple servers, but only runs on the primary.
+ `MAUTIC_BASE` - The full path to the Mautic install, eg: `/srv/www/mautic`
+ `MAUTIC_OPTS` - Options that will be passed to the scripts, generally want: `--no-interaction --no-ansi`

Defaults we use, feel free to change to fit your setup, see https://docs.mautic.org/en/setup/cron-jobs for more information.

```
CAMPAIGNS_BATCH_LIMIT="--batch-limit=300"
SEGMENT_BATCH_LIMIT="--batch-limit=300"
CLEANUP_DAYS="--days-old=35"
EMAIL_MSG_LIMIT="--message-limit=1000"
MAX_CONTACTS="--max-contacts=300"
BROADCAST_LIMIT="--limit=500"
```

## Deployment

+ Clone this repository to /srv/mautic-scripts
```
git clone https://github.com/ttpears/mautic-cron-scripts.git /srv/mautic-scripts
```
+ Give MAUTIC_USER permission to write the logs (skip if you're running these commands as the same user):
```
chown $MAUTIC_USER:$MAUTIC_USER /srv/mautic-scripts/logs
```
+ Symlink this file to somewhere under `/etc/cron.d/`, eg:  
```
ln -s /srv/mautic-scripts/mautic-crons /etc/cron.d/
```
+ Enable log rotation
```
ln -s /srv/mautic-scripts/mautic-scripts-log-rotation.conf /etc/logrotate.d/
```
