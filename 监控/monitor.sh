#!/bin/bash
# sh monitor.sh monitor.cfg > /dev/null 2>&1
# 系统监控：
# 网络 内存 CPU 磁盘
# 超过配置压力, 邮件发送${mail_to}帐号告警

readcfg() {
	cat ${monitor_cfg}|sed -e '/^;/d;/^$/d'|awk -F= '$1=="'$1'" {print $2}'
}

send_mail() {
 	echo -e "Hi,\n\t${hostname} occurred a problem!\n" >  ${file_tmp}
	echo -e "\n" >> ${file_tmp}
    	cat ${file_error_log} >> ${file_tmp}
    	echo -e "\n\n--${hostname}" >> ${file_tmp}
    	cat ${file_tmp} | mail -s "!Important:The ${hostname} monitor warn" ${mail_to} > /dev/null 2>&1 &
}

monitor() {
    	count_users=$(/usr/bin/who|wc -l)
    	avg_load=$(uptime|awk -F"load average:" '{print $2}'|awk -F, '{print $3}'|sed 's/ *//')
    	total_memery=$(free |sed -n "2p"|awk '{print $2}')
    	used_memery=$(free |sed -n "2p"|awk '{print $3}')
    	rate_memery=$(awk 'BEGIN {x='${used_memery}';y='${total_memery}';printf "%.2f\n",(x/y)*100}')
    	total_swap=$(free |sed -n "2p"|awk '{print $2}')
    	used_swap=$(free |sed -n "2p"|awk '{print $3}')
    	rate_swap=$(awk 'BEGIN {x='${used_swap}';y='${total_swap}';printf "%.2f\n",(x/y)*100}')
    	avg_cpu_idle=$(iostat -c 1 2|awk 'NR==7 {print $6}')
    	rate_cpu=$(awk 'BEGIN {i='${avg_cpu_idle}';printf "%.2f\n",100-i}')
    	io_state=`iostat -x 1 1|awk '{if ($1 ~/^sd/) print $1,$2"%"}'|xargs`

    	disk=$(df|sed -e '1d;s/\/dev\///g'|awk '{printf "%s:%s\n",$1,$5}'|xargs)

    	# save data
    	echo -e ">>>>----------------------------------------------------------------------------------------
    	${hostname} ${curr_time}
    	Login   User: [${count_users} user login]
    	Load average: ${avg_load}
    	Memory usage: ${rate_memery}%
    	Swap   usage: ${rate_swap}%
    	CPU    usage: ${rate_cpu}%
    	Hard-disk    IO: ${io_state}
    	Hard-disk space: ${disk}\n----------------------------------------------------------------------------------------<<<<" > ${file_tmp}
    	cat ${file_tmp} >> ${file_log}

    	#Check CPU
    	if [[ $(echo "${rate_cpu}>=${pole_cpu}"|bc) -eq 1 ]]; then
        	echo "Current CPU use rate:${rate_cpu}%, more than ${pole_cpu}% -- ${curr_time}" >> ${file_error_log}
        	echo "Current CPU use rate:${rate_cpu}%, more than ${pole_cpu}% -- ${curr_time}" >> ${file_log}
        	send_mail
    	fi

    	#Check memery
    	if [[ $(echo "${rate_memery}>=${pole_memery}"|bc) -eq 1 ]]; then
        	echo "Current memery use rate:${rate_memery}%, more than ${pole_memery}% -- ${curr_time}"  >> ${file_error_log}
        	echo "Current memery use rate:${rate_memery}%, more than ${pole_memery}% -- ${curr_time}"  >> ${file_log}
        	send_mail
    	fi

    	#Check Load average
    	if [[ $(echo "${avg_load}>=${pole_load}"|bc) -eq 1 ]]; then
        	echo "Load average every 15 minutes is ${avg_load}, more than ${pole_load} -- ${curr_time}" >> ${file_error_log}
        	echo "Load average every 15 minutes is ${avg_load}, more than ${pole_load} -- ${curr_time}" >> ${file_log}
        	send_mail
    	fi
    	
	#Check Hard-disk space
    	for free_disk in `df|sed -e '1d;s/%//g'|awk '{print $5}'|xargs` ; do
        	if [[ "${free_disk}" -ge "${pole_ide}" ]]; then
            		echo "Current hard disk use rate:${pole_ide}% -- ${curr_time}" >> ${file_error_log}
            		echo "Current hard disk use rate:${pole_ide}% -- ${curr_time}" >> ${file_log}
            		send_mail
            		break
        	fi
    	done
    	
	#Check hard disk I/O
    	for io_disk in `iostat -x 1 1|awk '{if ($1 ~/^sd/) print $2}'`
    	do
        	DiskIoTest=$(echo "${io_disk}>=${pole_hdio}"|bc)
        	if [[ $(echo "${io_disk}>=${pole_hdio}"|bc) -ne 0 ]]; then
            		echo "Current hard disk I/O is ${io_disk}%, more than ${pole_hdio}% -- ${curr_time}" >> ${file_error_log}
            		echo "Current hard disk I/O is ${io_disk}%, more than ${pole_hdio}% -- ${curr_time}" >> ${file_log}
            		send_mail
        	    	break
        	fi
    	done
}

main() {
	hostname=`hostname`
	curr_date=`date +%Y%m%d`
	curr_time=`date "+%Y-%m-%d %H:%M:%S"`

	#Check the system environment
    	path_who=`which who`
    	path_top=`which top`
    	path_iostat=`which iostat`

    	if [[ ${path_iostat} == '' ]]; then
        	echo 'sysstat does not be installed, you should install it firstly!'
        	exit 1
    	fi

    	pole_cpu=`readcfg pole_cpu`
    	pole_memery=`readcfg pole_memery`
    	pole_load=`readcfg pole_load`
    	pole_ide=`readcfg pole_ide`
    	pole_hdio=`readcfg pole_hdio`
    	monitor_network_interface="`readcfg monitor_network_interface`"

	log_path=`readcfg log_path`
	if [[ ! -d ${log_path} ]]; then
                mkdir ${log_path}
        fi

    	mail_to=`readcfg mail_to`
    	if [[ ${mail_to} == '' ]]; then
        	echo 'You should set the mail recipient firstly!'
        	exit 1
    	fi
	
	file_tmp="${log_path}/.tmp"
	file_log="${log_path}/${curr_date}.log"
        file_error_log="${log_path}/error_${curr_date}.log"

	#Run monitor
	monitor

	rm -rf ${file_tmp}
}

monitor_cfg="$1"

main
