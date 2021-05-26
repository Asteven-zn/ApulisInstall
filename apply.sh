#!/bin/bash

echo -e "\n---------------------------down load docker image----------------------------"

image=(
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/custom-user-dashboard-backend:v1.5.0-rc8"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/dlworkspace_webui3:v1.5.0-rc8"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/dlworkspace_restfulapi2:v1.5.0-rc8"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/aiarts-frontend:v1.5.0-rc8"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/aiarts-backend:v1.5.0-rc7"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/dlworkspace_openresty:latest"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/custom-user-dashboard-frontend:v1.5.0-rc8"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/postgres:11.10-alpine"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/nginx:1.9"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/vc-webhook-manager:v0.0.1"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/vc-scheduler:v0.0.1"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/vc-controller-manager:v0.0.1"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/watchdog:1.9"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/grafana-zh:6.7.4"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/job-exporter:1.9"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/istio-proxy:latest"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/istio-pilot:latest"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/grafana:6.7.4"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/prom/prometheus:v2.18.0"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/directxman12/k8s-prometheus-adapter:v0.7.0"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/jessestuart/prometheus-operator:v0.38.0"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/redis:5.0.6-alpine"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/prom/node-exporter:v0.18.1"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/nvidia/k8s-device-plugin:1.11"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/busybox:v1.28"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/dlworkspace_image-label:latest"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/knative-serving-queue:latest"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/knative-serving-activator:latest"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/knative-serving-autoscaler:latest"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/knative-serving-controller:latest"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/knative-serving-webhook:latest"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/knative-net-istio-controller:latest"
    "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/knative-net-istio-webhook:latest"
)

for im in ${image[*]}
do
        #echo $im
        docker pull $im
done

echo -e "\n-------------------------------准备环境yaml文件----------------------------"
base_dir=`pwd`

cp -r yaml build

arr1=(
    "storage-nfs"
    "nvidia-device-plugin"
    "postgres"
    "restfulapi2"
    "custom-user-dashboard"
    "jobmanager2"
    "custommetrics"
    "monitor"
    "nginx"
    "openresty"
    "webui3"
    "aiarts-backend"
    "aiarts-frontend"
#    "mlflow"
    "volcanosh"
    "image-label"
)

#修改环境ip
echo -e "\n-------------------------------配置环境IP----------------------------"

for item1 in ${arr1[*]}
do
        #echo $item1
        n=`cd $base_dir/build/$item1 && ls -l | grep ^- | awk -F " +" '{print $9}'`
        #old_ip=`grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' aiarts-backend/01.aiarts_cm.yaml | tail -1`
        #echo $n
        cd $base_dir/build/$item1 && for file in $n ; do ( sed -i s/conip/192.168.3.183/g $file); done ; cd $base_dir
        #cd $base_dir/build/$item1 && for file in $n ; do echo $file; done ; cd $base_dir

done

echo -e "\n---------------running Apulis check nfs status------------------------"
stat=`systemctl status rpcbind | grep Active | awk -F " +" '{print $3}'`

if [[ $stat = "active" ]];then
        echo -e "nfs is installed"
else
        bash nfs.sh
fi

#启动上层pod服务
echo -e "\n-------------------------------running Apulis AI Platform service ----------------------------"

# for 遍历服务目录
for item1 in ${arr1[*]}
do
	#echo $item1
	n=`cd $base_dir/build/$item1 && ls | grep '^[0-9]'`
	#echo $n
	cd $base_dir/build/$item1 && for file in $n ; do ( echo $file; kubectl apply -f $file ); done ; cd $base_dir
        #cd $base_dir/build/$item1 && for file in $n ; do ( echo $file); done ; cd $base_dir
done

sleep 3

echo -e "\n-----------------------------------------running pre-render ------------------------------------"

cd $base_dir/build/istio && bash pre-render.sh && cd $base_dir

arr2=(
    "knative"
    "kfserving"
#    "cvat"
)

for item2 in ${arr2[*]}
do
	#echo $item2
	n=`cd $base_dir/build/$item2 && ls | grep '^[0-9]'`
	#echo $n
	cd $base_dir/build/$item2 && for file in $n ; do ( echo $file; kubectl apply -f $file ); done ; cd $base_dir
	bash preset_models.sh
    
done

if [ $? -ne 0 ];then
    echo -e "\nApulis AI Platform Installer failed----------------------------------------------------------"
else    
    echo -e "\nApulis AI Platform Installer succeed---------------------------------------------------------"
    kubectl get node
fi
