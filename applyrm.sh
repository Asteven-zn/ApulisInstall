#!/bin/bash

base_dir=`pwd`

echo -e "\n---------------------------------------uninstall pre-render -------------------------------------"

arr1=(
#    "cvat"
    "kfserving"
    "knative"
)

for item1 in ${arr1[*]}
do
	#echo $item
	n=`cd $base_dir/build/$item1 && ls | grep '^[0-9]'`
	#echo $n
	cd $base_dir/build/$item1 && for file in $n ; do ( echo $file; kubectl delete -f $file ); done ; cd $base_dir

done

sleep 3

echo -e "\n-------------------------------uninstall Apulis AI Platform service ----------------------------"

arr2=(
    "volcanosh"
#    "mlflow"
    "aiarts-frontend"
    "aiarts-backend"
    "webui3"
    "openresty"
    "nginx"
    "monitor"
    "custommetrics"
    "jobmanager2"
    "custom-user-dashboard"
    "restfulapi2"
    "postgres"
    "nvidia-device-plugin"
    "storage-nfs"
)

#cd istio && bash pre-render.sh && cd ../

#length=${#arr}
#echo "长度为：$length"

# for 遍历服务目录
for item2 in ${arr2[*]}
do
	#echo $item
	n=`cd $base_dir/build/$item2 && ls | grep '^[0-9]'`
	#echo $n
	cd $base_dir/build/$item2 && for file in $n ; do ( echo $file; kubectl delete -f $file ); done ; cd $base_dir

done

if [ $? -ne 0 ];then
    echo -e "\nApulis AI Platform UnInstaller failed"
else    
    echo -e "\nApulis AI Platform UnInstaller succeed"
fi

#ls -l | grep ^d | awk -F " +" '{print $9}' | xargs rm -rf 
rm -rf build
rm -rf app

echo -e "\n-------------------------------delete nfsdate ----------------------------"

systemctl stop nfs-kernel-server
systemctl disable nfs-kernel-server

systemctl stop rpcbind
systemctl disable rpcbind

rm -rf /etc/exports
rm -rf /data/nfs
