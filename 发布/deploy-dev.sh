#!/usr/bin/env bash
# sh deploy-dev.sh myapp-admin
# 部署应用 构建,打包,发布
# FROM_DIR: 源码目录
# TO_USER:  发布目标机器用户
# TO_HOST:  发布目标机器主机
# TO_DIR:   发布目录

FROM_DIR=
TO_USER=
TO_HOST=
TO_DIR=

APP=$1

echo " 1) cd ${FROM_DIR}"
cd ${FROM_DIR}

echo " 2) build project ${APP}..."
mvn clean
mvn package -Dmaven.test.skip=true -Pdev -pl ${APP} -am
jar_package=`find ${FROM_DIR}/${APP}/target -name "*.jar"`

echo " 3) scp ${jar_package} ${TO_USER}@${TO_HOST}:${TO_DIR}/${APP}/${jar_package}.swp"
scp ${jar_package} ${TO_USER}@${TO_HOST}:${TO_DIR}/${APP}/${jar_package}.swp

echo " 4) ${TO_USER}@${TO_HOST} ${TO_DIR}/run.sh restart..."

ssh -l ${TO_USER} ${TO_HOST} "cd ${TO_DIR}/${APP};
                          mv ${jar_package}.swp ${jar_package};
                          sh restart.sh;"

echo done!
exit 0
