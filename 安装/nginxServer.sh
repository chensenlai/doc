#!/bin/bash

NGINX_HOME="/usr/local/nginx"

start(){
	nohup $NGINX_HOME/sbin/nginx >$NGINX_HOME/logs/nohup.out 2>&1 &
}

stop(){
	nohup $NGINX_HOME/sbin/nginx -s stop >$NGINX_HOME/logs/nohup.out 2>&1 &
}

reload(){
	 nohup $NGINX_HOME/sbin/nginx -s reload >$NGINX_HOME/logs/nohup.out 2>&1 &
}

restart(){

	stop

	start
}

main(){

	case $1 in

	start)

		start

		echo "nginx start!"

		;;

	stop)


		stop

		echo "nginx stop!"

		;;

	restart)


		restart

		echo "nginx restart!"

		;;

	reload)

		reload

		echo "nginx reload!"

		;;

	*)
		echo "unknow command $1, usage ./nginxServer.sh [start|stop|restart|reload]"
	esac

	exit 0

}

main $1
