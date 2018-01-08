#!/bin/bash

#OID
TYPE_OID=.1.3.6.1.4.1.6387.1.2.3.3.1.2
Process_Name_OID=.1.3.6.1.4.1.6387.1.2.3.3.1.1.18
Threshold_Value_OID=.1.3.6.1.4.1.6387.1.2.3.3.1.1.1
Current_Value_OID=.1.3.6.1.4.1.6387.1.2.3.3.1.1.2


function send_trap()
{
	MEM_USAGE=$1
	TIME_STAMP=`cat /proc/uptime | awk '{print ($1*100)}'`
	snmptrap -v1 -c public $NMS_IP $TYPE_OID $HOST_IP 6 20 $TIME_STAMP $Process_Name_OID s $HOSTNAME $Threshold_Value_OID s $THRESHOLD% $Current_Value_OID s $MEM_USAGE%
	if [ $? -eq 0 ]; then
		echo "Send trap successfully."
	else
		echo "Failed to send trap."
	fi
}


function check_memory_usage()
{
	TOTAL=`free | grep -i Mem | awk '{print $2}'`
	USED=`free | grep -i Mem | awk '{print $3}'`
	MEM_USAGE=`awk -v x=$USED -v y=$TOTAL 'BEGIN{printf "%.2f", x*100/y}'`
	echo "Current memory usage($MEM_USAGE%), threshold($THRESHOLD%)"
	
	NEED_TO_SEND=`awk -v x=$MEM_USAGE -v y=$THRESHOLD 'BEGIN{if(x>y){print "YES"}else{print "NO"}}'`
	if [ "$NEED_TO_SEND"x = "YES"x ]; then
		echo "Need to send trap!"
		send_trap $MEM_USAGE
	else
		echo "Do not send trap."
	fi
}


# Script starts here
if [ $# -lt 3 ]; then
	echo "[USAGE] $0 NMS_IP HOST_IP THRESHOLD"
	exit
fi

declare -x NMS_IP=$1
declare -x HOST_IP=$2
declare -x THRESHOLD=$3

check_memory_usage


