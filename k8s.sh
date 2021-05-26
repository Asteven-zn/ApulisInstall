#!/bin/bash
#获取服务器ip
host_ip=$1

echo $host_ip

#下载calico image
echo -e "\n-------------------------------down calico image-----------------------------"

calico_image=(
  "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/calico/node:v3.19.1"
  "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/calico/pod2daemon-flexvol:v3.19.1"
  "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/calico/cni:v3.19.1"
  "harbor.apulis.cn:8443/aiarts_v1.5.0_rc8/apulistech/calico/kube-controllers:v3.19.1"
)

for c_image in ${calico_image[*]}
  do
    docker pull $c_image
done

#安装k8s
echo -e "\n-------------------------------install kubernetes----------------------------"

k8s_image=(
    "registry.aliyuncs.com/google_containers/kube-proxy:v1.18.0"
    "registry.aliyuncs.com/google_containers/kube-apiserver:v1.18.0"
    "registry.aliyuncs.com/google_containers/kube-controller-manager:v1.18.0"
    "registry.aliyuncs.com/google_containers/kube-scheduler:v1.18.0"
    "registry.aliyuncs.com/google_containers/pause:3.2"
    "registry.aliyuncs.com/google_containers/coredns:1.6.7"
    "registry.aliyuncs.com/google_containers/etcd:3.4.3-0"
)

for k_image in ${k8s_image[*]}
  do
    docker pull $k_image
done

apt-get update && apt-get install apt-transport-https -y

curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -

echo "deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list 

apt-get update

apt-get install -y kubelet=1.18.0-00 kubeadm=1.18.0-00 kubectl=1.18.0-00

kubeadm init  --apiserver-advertise-address=$host_ip \
        --image-repository=registry.aliyuncs.com/google_containers \
        --kubernetes-version=1.18.0 \
        --control-plane-endpoint="$host_ip:6443" \
        --service-cidr=10.68.0.0/16 \
        --pod-network-cidr=172.20.0.0/16 \
        --service-dns-domain=client.local

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo -e "\n-------------------------------install calico network----------------------------"
#kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl apply -f calico.yaml

if [ $? -ne 0 ];then
        echo -e "*************************install calico network failed********************************"
else    
        echo -e "*************************install calico network succeed********************************"
        kubectl get node
fi

sleep 3

#kubectl 命令自动补全
kc=`grep kubectl ~/.bashrc`

if [ $? -ne 0 ];then
        apt install bash-completion
        echo "source /usr/share/bash-completion/bash_completion" >> ~/.bashrc
        echo "source <(kubectl completion bash)" >> ~/.bashrc
        source ~/.bashrc
fi

apt install bash-completion
echo "source /usr/share/bash-completion/bash_completion" >> ~/.bashrc
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc

#节点打lable
echo -e "\n-------------------------------node lable tag----------------------------"
kubectl label node $HOSTNAME node-role.kubernetes.io/worker=worker
kubectl taint nodes --all node-role.kubernetes.io/master-
bash lab.sh

##添加/opt/kube/bin/kubectl
echo -e "\n------------------------add /opt/kube/bin/kubectl-------------------------"
if [[ ! -d "/opt/kube/bin/" ]];then
    mkdir -p /opt/kube/bin
    cp /usr/bin/kubectl /opt/kube/bin/
fi
