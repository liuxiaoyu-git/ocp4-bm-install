echo "STEP：Prepare Auto Config Files for CoreOS"

rm -rf ${IGN_PATH}/set-*

#
creat_auto_config_file(){

cat << EOF > ${IGN_PATH}/set-${NODE_NAME}
nmcli connection modify "Wired Connection" ipv4.addresses ${IP}/${NETMASK}
nmcli connection modify "Wired Connection" ipv4.dns ${DNS_IP}
nmcli connection modify "Wired Connection" ipv4.gateway ${GATEWAY_IP}
nmcli connection modify "Wired Connection" ipv4.method manual
nmcli connection down "Wired Connection"
nmcli connection up "Wired Connection"

sudo coreos-installer install /dev/sda --insecure-ignition --ignition-url=http://${YUM_DOMAIN}/ignition/${OCP_CLUSTER_ID}/${NODE_TYPE}.ign --firstboot-args 'rd.neednet=1' --copy-network

EOF
}

#创建BOOTSTRAP启动定制文件
NODE_TYPE="bootstrap"
NODE_NAME="bootstrap"
IP=${BOOTSTRAP_IP}
creat_auto_config_file 

#创建master-0启动定制文件
NODE_TYPE="master"
NODE_NAME="master-0"
IP=${MASTER0_IP}
creat_auto_config_file

#创建master-1启动定制文件
NODE_TYPE="master"
NODE_NAME="master-1"
IP=${MASTER1_IP}
creat_auto_config_file

#创建master-2启动定制文件
NODE_TYPE="master"
NODE_NAME="master-2"
IP=${MASTER2_IP}
creat_auto_config_file

#创建worker-0启动定制文件
NODE_TYPE="worker"
NODE_NAME="worker-0"
IP=${WORKER0_IP}
creat_auto_config_file

#创建worker-1启动定制文件
NODE_TYPE="worker"
NODE_NAME="worker-1"
IP=${WORKER1_IP}
creat_auto_config_file

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

echo ========================================================================================================
echo ================================= Auto Config Files Generated for CoreOS ===============================
ls -al ${IGN_PATH}/set-*
