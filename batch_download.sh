#!/bin/bash 
HOSTNAME=voipmon.ciphercloud.co.za
TERM=xterm-256color
SHELL=/bin/bash
HISTSIZE=1000
SSH_CLIENT=197.234.170.138 34154 22
QTDIR=/usr/lib64/qt-3.3
QTINC=/usr/lib64/qt-3.3/include
SSH_TTY=/dev/pts/0
USER=root
MAIL=/var/spool/mail/root
PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
PWD=/root
LANG=en_ZA.UTF-8
HISTCONTROL=ignoredups
SHLVL=1
HOME=/root
LOGNAME=root
QTLIB=/usr/lib64/qt-3.3/lib
CVS_RSH=ssh
LESSOPEN=||/usr/bin/lesspipe.sh %s
G_BROKEN_FILENAMES=1
_=/bin/env
OLDPWD=/root/audio_downloads

#########################################################
## Basic settings, not spaces alowed in dir/file names
##
##
## MYSQL query to detect cdrs you want to download audio from
#query=`mysql voipmonitor -e "select id from cdr where calldate >= '2020-09-15' and calldate < '2021-01-26' and caller_domain = '192.168.88.232' and connect_duration>0 order by id\G"|grep id|cut -d ':' -f 2`
query=`mysql -u root --password=r00t@bUg! voipmonitor -e "select id from cdr where calldate >= '2020-11-15 00:00:00' and calldate < '2021-01-01 00:00:00' and connect_duration>0 and ( caller_domain = '41.87.194.80' or called_domain = '41.87.194.80' ) and ( substring(caller, -9) in ('113631415', '113631416', '118185760', '118185769') or substring(called, -9) in ('113631415', '113631416', '118185760', '118185769')  ) order by id\G"|grep id|cut -d ':' -f 2`
##
## Maximum count of simultaneous cdr api calls
simmax=2
##
## Where the script will do the audio
workdir=/root/audio_downloads
##
## Where is voipmonitor GUI located
guidir=/var/www/html
##
## GUI user with audio download privilege
user=janklaver
password=17D%s1dO
##
## End common settings
##########################################################
#audio files will be in:
audiodir=$workdir/audio
#log
day=`date "+%m-%d-%Y"`
logfile=$workdir/log/${day}.txt
#where to exec calls to voipmonitor
tmprunfile=$workdir/run/tmp.sh
#DEBUG - Test run? do (nothing) just logs =1 and dirs
dryrun=0
#make dirs
mkdir -p $workdir
mkdir -p $audiodir
mkdir -p `dirname $logfile`
mkdir -p `dirname $tmprunfile`
atonce=1
getcmd=""
tmpgetcmd=""
for id in ${query[*]}
do
	#getcmd="$tmpgetcmd echo '{\"task\": \"getVoiceRecording\", \"user\": \"$user\", \"password\": \"$password\", \"params\": {\"cdrId\": \"$id\", \"ogg\":\"true\"}}' | php api.php > $audiodir/$id.ogg"
	getcmd="$tmpgetcmd echo '{\"task\": \"getVoiceRecording\", \"user\": \"$user\", \"password\": \"$password\", \"params\": {\"cdrId\": \"$id\"}}' | php api.php > $audiodir/$id.wav"
	if [ "1$atonce" = "1$simmax" ]; then
		atonce=1
		echo "`date "+%H:%M:%S"`" >> $logfile
		echo $getcmd >> $logfile
		#run command
		if [ "1$dryrun" == '11' ]; then 
			echo $getcmd
		else
			echo "#/bin/bash" > $tmprunfile
			echo "cd $guidir/php" >> $tmprunfile
			echo "$getcmd" >> $tmprunfile
			chmod +x $tmprunfile
			$tmprunfile
		fi
		echo "`date "+%H:%M:%S"`" >> $logfile
		echo >> $logfile
		getcmd=""
	else
		((atonce+=1))
		tmpgetcmd="$getcmd&"
    fi
	echo >> $logfile
done
if [ "11" != "1$atonce" ]; then
	echo "`date "+%H:%M:%S"`" >> $logfile
	echo $getcmd >> $logfile
	if [ "1$dryrun" == '11' ]; then 
		echo $getcmd
	else
		echo "#/bin/bash" > $tmprunfile
		echo "cd $guidir/php" >> $tmprunfile
		echo "$getcmd" >> $tmprunfile
		chmod +x $tmprunfile
		$tmprunfile
	fi
	echo "`date "+%H:%M:%S"`" >> $logfile
    echo >> $logfile
fi
echo >> $logfile
