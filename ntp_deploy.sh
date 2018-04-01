#!/bin/bash

# checks if ntp daemon is installed and installs it if needed
which ntpd > /dev/null 2>&1
[[ $? == 0 ]] && echo "Skipping ntpd installation" || sudo apt-get -y install ntp

cron_path="/var/spool/cron/crontabs/root"

# modifies /etc/ntp.conf and saves the sample
if [[ -f /etc/ntp.conf ]]; 
	then sed -i '/^pool/d;/^server/d' /etc/ntp.conf;
	sed -i '/# more information/apool ua.pool.ntp.org iburst' /etc/ntp.conf;
	else echo "cfg file does not exist"; exit 1;
fi
cp /etc/ntp{,_sample}.conf

systemctl restart ntp

# creates the cron job
[[ -e ${cron_path} ]] || ( echo -e "SHELL=/bin/bash\nHOME=/\nMAILTO=root" > "${cron_path}" && chmod 600 "${cron_path}" )
grep -q "ntp_verify" "${cron_path}" || echo "* * * * * `dirname $(readlink -f $0)`/ntp_verify.sh" >> "${cron_path}"
