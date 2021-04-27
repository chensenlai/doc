#!/usr/bin/env bash
# sh run.sh
# 启动脚本
# JAVA_HOME: java目录
# APP_HOME: app应用的目录
# APP_JAR: app应用打包后jar名
# APP_WORK: app应用工作目录
# JAVA_OPTS: JAVA启动参数

JAVA_HOME=
APP_HOME=
APP_JAR=
APP_WORK="$APP_HOME/work"

# JAVA进程启动参数
# 启动打印VM与默认不一样参数  -XX:+PrintCommandLineFlags
# 性能相关 -XX:-UseBiasedLocking -XX:-UseCounterDecay -XX:AutoBoxCacheMax=20000
# 内存相关 -Xmx1024m -Xms1024m -Xmn256m -XX:PermSize=128m -XX:MaxPermSize=256m -XX:MaxDirectMemorySize=512m -XX:ReservedCodeCacheSize=100M
# CMS GC相关 -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=75 -XX:+UseCMSInitiatingOccupancyOnly -XX:MaxTenuringThreshold=6 -XX:+ExplicitGCInvokesConcurrent -XX:+ParallelRefProcEnabled
# GC相关 -Xloggc:/dev/shm/app-gc.log -XX:+PrintGCApplicationStoppedTime -XX:+PrintGCDateStamps -XX:+PrintGCDetails
# 异常日志相关 -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${LOGDIR}/ -XX:ErrorFile=${LOGDIR}/hs_err_%p.log
# JMX相关 -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=7200 -Dcom.sun.management.jmxremote.rmi.port=7200 -Djava.rmi.server.hostname=192.168.1.2 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=true -Dcom.sun.management.jmxremote.acccess.file=./management/jmxremote.access -Dcom.sun.management.jmxremote.password.file=./management/jmxremote.password
JAVA_OPTS=" -server -Xmx1024m -Xms1024m -Duser.timezone=GMT+08 -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:MaxTenuringThreshold=15 -Xloggc:$APP_WORK/gc.log  -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$APP_WORK/dump/"

# JAVA进程IP, 全局变量
psid=0

checkpid() {

	javaps=`$JAVA_HOME/bin/jps -l | grep "\<${APP_JAR}\>"`

	if [ -n "$javaps" ]; then

		psid=`echo $javaps | awk '{print $1}'`

	else

		psid=0

	fi
}


# 启动应用
start() {

	checkpid

	if [ $psid -ne 0 ]; then

		echo "================================"

		echo "warn: $APP_JAR already started! (pid=$psid)"

		echo "================================"

	else

		echo -n "Starting $APP_JAR ..."

		nohup $JAVA_HOME/bin/java $JAVA_OPTS -jar $APP_JAR >$APP_WORK/nohup.out 2>&1 &

		checkpid

		if [ $psid -ne 0 ]; then

			echo "(pid=$psid) [OK]"

		else

			echo "[Failed]"

		fi

	fi

}



# 停止应用
stop() {

	checkpid

	if [ $psid -ne 0 ]; then

		echo -n "Stopping $APP_JAR ...(pid=$psid) "

		kill -15 $psid

		if [ $? -eq 0 ]; then

			echo "[OK]"

		else

			echo "[Failed]"

		fi

    sleep 1

		checkpid

		if [ $psid -ne 0 ]; then

			stop

		fi

	else

		echo "================================"

		echo "warn: $APP_JAR is not running"

		echo "================================"

	fi

}


case $1 in

start)

	echo "start project......"

	start

	;;

stop)

	echo "stop project......"

	stop

	;;

restart)

	echo "restart project......"

	stop

	start

	;;

*)

esac

exit 0
