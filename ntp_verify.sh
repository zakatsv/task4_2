#!/bin/bash

sample="/etc/ntp_sample.conf"

# checks if ntp daemon is running and starts it if needed
pgrep ntpd > /dev/null 2>&1
[[ $? == 1 ]] && systemctl start ntp && echo "NOTICE: ntp is not running"

# checks if /etc/ntp.conf exists
if [[ -e /etc/ntp.conf ]];
then
#checks if /etc/ntp.conf was modified
diff -q /etc/ntp.conf ${sample} > /dev/null 2>&1
	if [[ $? == 1 ]]; 
	then
	echo "NOTICE: /etc/ntp.conf was changed. Calculated diff:";
	diff -u1 /etc/ntp.conf ${sample};
	cp -a /etc/ntp{_sample,}.conf;
	systemctl restart ntp
	logger "`basename $0`: cfg file restored"; 
	fi
else echo "NOTICE: /etc/ntp.conf was removed; restoring it..." && cp -a /etc/ntp{_sample,}.conf && logger "`basename $0`: missing cfg file restored";
fi


