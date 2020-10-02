\cp ~/.bashrc.origin ~/.bashrc > /dev/null 2>&1 || \cp ~/.bashrc ~/.bashrc.origin
#
cat << EOF >> ~/.bashrc

restoreFile(){
  if [ ! $# = 1 ]
  then
    echo "USAGE: "
    echo "   restoreFile <Your-FileName>"
  else
    touch ${1}
    \cp ${1}.origin ${1} > /dev/null 2>&1 || \cp ${1} ${1}.origin
  fi
}

verifyURL(){
  if [ \$# = 1 ]
  then
    HTTP_200="HTTP/1.1 200 OK"
    RESULT=\$(curl -I -s \${1} | head -n 1)
    if [ "\${RESULT:0:15}" = "\${HTTP_200:0:15}" ]
    then
      echo "\${1} can be accessed."
    else
      echo "ERROR! \${1} can not be accessed."
    fi
  else
    echo "Usage: verifyFile <HTTP_URL>"
  fi
}

checkNetworkInferface(){
  IP_1="\$(ip a show \${1} | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print \$2}' | cut -d "/" -f1)"
  IP_2="\$(hostname -I)"
  if [ "\$IP_1 " != "\$IP_2" ]
  then
    echo "The value of parameter \"NET_IF_NAME\" maybe is ERROR. "
    echo "Please confirm your IP address \"\$(hostname -I)\" is bound with \"\$NET_IF_NAME\" on your \"support\" node."
  else
    echo "Correct, IP \"\$IP_1\" belongs to \"\$NET_IF_NAME\"."
  fi
}

export OCP_VER="4.3.18"
export RHCOS_VER="4.3.8"
export OCP_CLUSTER_ID="ocp4-1"
export DOMAIN="example.internal"
export YUM_DOMAIN="yum.\${DOMAIN}:8080"
export REG_DOMAIN="registry.\${DOMAIN}:5000"              ## 容器镜像库的访问域名
export NODE_LIST="bootstrap master-0 worker-0 worker-1"   ## 主机节点名列表
export YUM_PATH="/data/OCP-\${OCP_VER}/yum"               ## 存放yum源的目录
export OCP_PATH="/data/OCP-\${OCP_VER}/ocp"               ## 存放OCP原始安装介质的目录
export REGISTRY_PATH="/data/registry"                     ## 容器镜像库存放的根目录
export BOOT_FILE_PATH="/data/boot-files"                  ## 用来存放所有启动CoreOS所需文件的目录
export RHCOS_ISO_PATH="\${BOOT_FILE_PATH}/rhcos-iso"      ## 用来存启动CoreOS所需ISO和RAW文件的目录
export IGN_PATH="\${BOOT_FILE_PATH}/ignition/\${OCP_CLUSTER_ID}"      ## 存放Ignition相关文件的目录

export NET_SEGMENT_IP=192.168.1
export NET_SEGMENT_PI=1.168.192

export BASTION_IP="\${NET_SEGMENT_IP}.13"                  ## 以下每对都是DNS用的正向IP和反向IP
export BASTION_PI="13.\${NET_SEGMENT_PI}"

export SUPPORT_IP="\${NET_SEGMENT_IP}.12"
export SUPPORT_PI="12.\${NET_SEGMENT_PI}"

export DNS_IP="\${NET_SEGMENT_IP}.12"
export DNS_PI="12.\${NET_SEGMENT_PI}"

export NTP_IP="\${NET_SEGMENT_IP}.12"
export NTP_PI="12.\${NET_SEGMENT_PI}"

export YUM_IP="\${NET_SEGMENT_IP}.12"
export YUM_PI="12.\${NET_SEGMENT_PI}"

export REGISTRY_IP="\${NET_SEGMENT_IP}.12"
export REGISTRY_PI="12.\${NET_SEGMENT_PI}"

export NFS_IP="\${NET_SEGMENT_IP}.12"
export NFS_PI="12.\${NET_SEGMENT_PI}"

export LB_IP="\${NET_SEGMENT_IP}.12"
export LB_PI="12.\${NET_SEGMENT_PI}"

export BOOTSTRAP_IP="\${NET_SEGMENT_IP}.100"
export BOOTSTRAP_PI="100.\${NET_SEGMENT_PI}"

export MASTER0_IP="\${NET_SEGMENT_IP}.101"
export MASTER0_PI="101.\${NET_SEGMENT_PI}"

export WORKER0_IP="\${NET_SEGMENT_IP}.110"
export WORKER0_PI="110.\${NET_SEGMENT_PI}"

export WORKER1_IP="\${NET_SEGMENT_IP}.111"
export WORKER1_PI="111.\${NET_SEGMENT_PI}"

export GATEWAY="192.168.1.1"
export NETMASK="255.255.255.0"
export REPO_NAME="ocp4/openshift4"                        ## 在Docker Registry中存放OpenShift核心镜像的Repository
export REG_SECRET="\${OCP_PATH}/secret/registry-secret.json"	 	## 指定一个文件，用来保存podman登录本地docker registry时所生成的secret，以便以后可免密登录
export SSH_PRI_FILE="\${IGN_PATH}/ssh-key/id_rsa"         ## Ignition私钥文件名
export NET_IF_NAME="enp0s3"	                              ## CoreOS启动时缺省创建的网卡名，该名称须和support节点的网卡名一致。KVM缺省用"ens3"；VMWare缺省用"ens192"；Virtualbox缺省用"enp0s3"
export RHCOS_METAL_URL="http://\${YUM_DOMAIN}/rhcos-iso/rhcos-\${RHCOS_VER}-x86_64-metal.x86_64.raw.gz"
export REPLICA_WORKER="0"                                 ## 在安装阶段，将WORKER的数量设为"0"
export REPLICA_MASTER="1"                                 ## 本文档的OpenShift集群只有1个master节点

EOF

source ~/.bashrc

echo =============================================================================================
echo =============== Complete Variables Setting. All Variables Will Be Used Are: =================
echo =============================================================================================

echo OCP_VER=${OCP_VER}
echo RHCOS_VER=${RHCOS_VER}
echo OCP_CLUSTER_ID=${OCP_CLUSTER_ID}
echo DOMAIN=${DOMAIN}
echo YUM_DOMAIN=${YUM_DOMAIN}
echo REG_DOMAIN=${REG_DOMAIN}
echo NODE_LIST=${NODE_LIST}
echo YUM_PATH=${YUM_PATH}
echo OCP_PATH=${OCP_PATH}
echo REGISTRY_PATH=${REGISTRY_PATH}
echo BOOT_FILE_PATH=${BOOT_FILE_PATH}
echo RHCOS_ISO_PATH=${RHCOS_ISO_PATH}
echo BASTION_IP=${BASTION_IP}
echo SUPPORT_IP=${SUPPORT_IP}
echo DNS_IP=${DNS_IP}
echo NTP_IP=${NTP_IP}
echo YUM_IP=${YUM_IP}
echo REGISTRY_IP=${REGISTRY_IP}
echo NFS_IP=${NFS_IP}
echo LB_IP=${LB_IP}
echo BOOTSTRAP_IP=${BOOTSTRAP_IP}
echo MASTER0_IP=${MASTER0_IP}
echo WORKER0_IP=${WORKER0_IP}
echo WORKER1_IP=${WORKER1_IP}
echo GATEWAY=${GATEWAY}
echo NETMASK=${NETMASK}
echo REG_SECRET=${REG_SECRET}
echo SSH_PRI_FILE=${SSH_PRI_FILE}
echo NET_IF_NAME=${NET_IF_NAME}
echo RHCOS_METAL_URL=${RHCOS_METAL_URL}
echo IGN_PATH=${IGN_PATH}
echo REPLICA_WORKER=${REPLICA_WORKER}
echo REPLICA_MASTER=${REPLICA_MASTER}

echo =============================================================================================
echo =========================== If error, correct it and re-run me. =============================
echo =============================================================================================
