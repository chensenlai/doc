#!/bin/bash
# sh mysqldump.sh > output.log 2>&1
# mysql数据库备份脚本, 备份保留7天
# MYSQL_USER: Mysql用户名
# MYSQL_PASSWORD: Mysql用户密码
# BACKUP_ROOT: 备份目录文件: 备份目录
# BACKUP_DB: 备份数据库名称: 备份数据库
# BACKUP_FILE: 备份文件名
# REMOTE_USER: 冗余备份远程机器用户名
# REMOTE_HOST: 冗余备份远程机器主机

MYSQL_USER=
MYSQL_PASSWORD=
BACKUP_ROOT=
BACKUP_DB=
BACKUP_FILE=
REMOTE_USER=
REMOTE_HOST=

BACKUP_DATE=`date +%Y-%m-%d`
BACKUP_EXIPRE_DATE=`date +%Y-%m-%d -d -7day`

# 备份sql
BACKUP_SQL=${BACKUP_FILE}_${BACKUP_DATE}.sql
# 打包压缩备份
BACKUP_SQL_TARGZ=${BACKUP_FILE}_${BACKUP_DATE}.tar.gz
# 已过期的备份
BACKUP_SQL_EXPIRE_TARGZ=${BACKUP_FILE}_${BACKUP_EXIPRE_DATE}.tar.gz
# 备份日志文件
BACKUP_LOG=mysqldump.log

cd ${BACKUP_ROOT}

# 1.全量备份mysql数据库
echo "`date +'%Y-%m-%d %H:%M:%S'` mysqldump ${BACKUP_DB} start." >> ${BACKUP_LOG}
mysqldump -u${MYSQL_USER} -p${MYSQL_PASSWORD} --single-transaction --flush-logs --master-data --databases ${BACKUP_DB} > ${BACKUP_SQL}

if [ $? -ne 0 ];then
	echo "`date +'%Y-%m-%d %H:%M:%S'` mysqldump ${BACKUP_DB} error." >> ${BACKUP_LOG}
	return
fi

# 2.数据库文件打包压缩, 删除备份过期文件
tar -zcvf ${BACKUP_SQL_TARGZ} ${BACKUP_SQL}
rm -f ${BACKUP_SQL}
rm -f ${BACKUP_SQL_EXPIRE_TARGZ}

# 3.拷贝到远端服务器,冗余备份
echo "`date +'%Y-%m-%d %H:%M:%S'` mysqldump ${BACKUP_DB} scp remote." >> ${BACKUP_LOG}
scp ${BACKUP_SQL_TARGZ} ${REMOTE_USER}@${REMOTE_HOST}:${BACKUP_ROOT}
ssh ${REMOTE_USER}@${REMOTE_HOST} rm -f ${BACKUP_ROOT}${BACKUP_SQL_EXPIRE_TARGZ}

echo "`date +'%Y-%m-%d %H:%M:%S'` mysqldump ${BACKUP_DB} finish." >> ${BACKUP_LOG}
