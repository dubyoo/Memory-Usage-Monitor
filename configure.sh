#!/bin/bash

CONFIG_FILENAME="config.ini"
CRONTAB_PATH="/etc/cron.d"
CRONJOB_FILENAME="memory-usage-check-cronjob"
SCRIPT_PATH="/root"
SCRIPT_FILENAME="memory-usage-check.sh"

function get_config()
{
        CONF_FILE=$1; ITEM=$2
        RESULT=`awk -F = '$1 ~ /'$ITEM'/ {print $2;exit}' $CONF_FILE`
        echo $RESULT
}

function build_cronjob_file()
{
	NMS_IP=$(get_config $CONFIG_FILENAME "NMS_IP")
	HOST_IP=$(get_config $CONFIG_FILENAME "HOST_IP")
	THRESHOLD=$(get_config $CONFIG_FILENAME "THRESHOLD")	
	INTERVAL=$(get_config $CONFIG_FILENAME "CHECK_INTERVAL")
	echo "NMS_IP($NMS_IP)  HOST_IP($HOST_IP)  THRESHOLD($THRESHOLD%)  CHECK_INTERVAL($INTERVAL min)"

	echo "SHELL=/bin/bash" > $CRONJOB_FILENAME
	echo "PATH=/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/X11R6/bin:/root/bin" >> $CRONJOB_FILENAME
	echo "MAILTO=" >> $CRONJOB_FILENAME
	echo "USER=root" >> $CRONJOB_FILENAME
	echo "LOGNAME=root" >> $CRONJOB_FILENAME
	echo "HOME=/root" >> $CRONJOB_FILENAME
	echo "*/$INTERVAL * * * *   root $SCRIPT_PATH/$SCRIPT_FILENAME $NMS_IP $HOST_IP $THRESHOLD" >> $CRONJOB_FILENAME
	echo >> $CRONJOB_FILENAME
}

function deploy()
{
	mv $CRONJOB_FILENAME $CRONTAB_PATH -f
	chmod 0644 $CRONTAB_PATH/$CRONJOB_FILENAME
	cp $SCRIPT_FILENAME $SCRIPT_PATH -f
	chmod 0755 $SCRIPT_PATH/$SCRIPT_FILENAME
}

function reload_crond()
{
        service crond status
        if [ $? -eq 0 ]; then
                service crond reload
        else
                service crond start
        fi
}

# Script starts here
build_cronjob_file
deploy
reload_crond


