#!/bin/bash

:<< 'END'
HOSTNAME=voipmon.ciphercloud.co.za
SHELL=/bin/bash
TERM=screen
HISTSIZE=1000
SSH_CLIENT=197.234.170.138 51864 22
QTDIR=/usr/lib64/qt-3.3
QTINC=/usr/lib64/qt-3.3/include
SSH_TTY=/dev/pts/1
USER=root
PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
MAIL=/var/spool/mail/root
STY=25772.pts-1.voipmon
PWD=/usr/local/bin
LANG=en_US.UTF-8
HISTCONTROL=ignoredups
HOME=/root
SHLVL=2
LOGNAME=root
QTLIB=/usr/lib64/qt-3.3/lib
WINDOW=0
LESSOPEN=||/usr/bin/lesspipe.sh %s
G_BROKEN_FILENAMES=1
_=/bin/env
OLDPWD=/var/spool/voipmonitor
END

set -x

echo "$(date): Starting Backup" >> /var/log/backup.log

today=$(date --date="today" +"%Y-%m-%d")
#yesterday=$(date --date="yesterday" +"%Y-%m-%d")
yesterday="2023-07-17"

if grep -qs '/DATA ' /proc/mounts; then
	if [ "$1" == "yesterday" ]
	then
		echo "Backup Date: $yesterday" >> /var/log/backup.log
		for olddir in `find /DATA/ -maxdepth 1 -name '20*' -ctime +105`
			do rm -rf $olddir 
		done
	
		rsync -a --numeric-ids /var/spool/voipmonitor/$yesterday /DATA/.
		#cp -rp /var/spool/voipmonitor/$yesterday /DATA/. >> /var/log/backup.log 2>&1
		exitstat=$?
		echo "Exit Status: $exitstat" >> /var/log/backup.log
		if [ "$exitstat" -ne "0" ]
		then
			echo "$(date): Backup failed!." >> /var/log/backup.log
			mail -s "Voipmon backup failed!" jan@cipherwave.co.za
		else
			echo "$(date): Backup complete." >> /var/log/backup.log
			rm -rf /var/spool/voipmonitor/$yesterday
			/usr/local/bin/lndir $yesterday
		fi
	elif [ "$1" == "today" ]
	then
		echo "Backup Date: $today" >> /var/log/backup.log
		rsync -a --numeric-ids /var/spool/voipmonitor/$today /DATA/.
		exitstat=$?
		echo "Exit Status: $exitstat" >> /var/log/backup.log
		if [ "$exitstat" -ne "0" ]
		then
			echo "$(date): Backup failed!." >> /var/log/backup.log
			mail -s "Voipmon backup failed!" jan@cipherwave.co.za
		else
			echo "$(date): Backup complete." >> /var/log/backup.log
		fi
	else
		echo "WARNING: No or invalid CLI parameter specified" >> /var/log/backup.log
	fi
else
	echo "WARNING: Backup destination not mounted!!!" >> /var/log/backup.log
	mail -s "Voipmon storage not mounted, please investigate!" jan@cipherwave.co.za
fi

exit 0
