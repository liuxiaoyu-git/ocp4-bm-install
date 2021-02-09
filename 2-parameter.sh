export OCP_CLUSTER_ID="ocp4-1"

##\cp ~/.bashrc-${OCP_CLUSTER_ID}.origin ~/.bashrc-${OCP_CLUSTER_ID} > /dev/null 2>&1 || \cp ~/.bashrc-${OCP_CLUSTER_ID} ~/.bashrc-${OCP_CLUSTER_ID}.origin > /dev/null 2>&1 


cat << EOF > ~/.bashrc-${OCP_CLUSTER_ID}

setVAR(){
  if [ \$# = 0 ]
  then
    echo "USAGE: "
    echo "   setVAR VAR_NAME VAR_VALUE    # Set VAR_NAME with VAR_VALUE"
    echo "   setVAR VAR_NAME              # Delete VAR_NAME"
  elif [ \$# = 1 ]
  then
    sed -i "/\${1}/d" ~/.bashrc-${OCP_CLUSTER_ID}
source ~/.bashrc-${OCP_CLUSTER_ID}
unset \${1}
    echo \${1} is empty
  else
    sed -i "/\${1}/d" ~/.bashrc-${OCP_CLUSTER_ID}
    echo export \${1}=\"\${2}\" >> ~/.bashrc-${OCP_CLUSTER_ID}
source ~/.bashrc-${OCP_CLUSTER_ID}
echo \${1}="\${2}"
  fi
  echo ${VAR_NAME}
}

restoreFile(){
  if [ \$# != 1 ]
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
  if [ "\$IP_1" != "\$IP_2" ]
  then
    echo "The value of parameter \"NET_IF_NAME\" maybe is ERROR. "
    echo "Please confirm your IP address \"\$(hostname -I)\" is bound with \"\$NET_IF_NAME\" on your \"support\" node."
  else
    echo "Correct, IP \"\$IP_1\" belongs to \"\$NET_IF_NAME\"."
  fi
}

export OCP_VER="4.6.8"
export RHCOS_VER="4.6.8"
export OCP_CLUSTER_ID="\${OCP_CLUSTER_ID}"
export DOMAIN="example.internal"

export NODE_LIST="bootstrap master-0 master-1 master-2 worker-0 worker-1"   ## 主机节点名列表
export REPLICA_WORKER="0"                                 ## 在安装阶段，将WORKER的数量设为"0"
export REPLICA_MASTER="3"                                 ## 本文档的OpenShift集群有3个master节点

export YUM_DOMAIN="yum.\${DOMAIN}:8080"
export YUM_PATH="/data/OCP-\${OCP_VER}/yum"               ## 存放yum源的目录

export OCP_PATH="/data/OCP-\${OCP_VER}/ocp"               ## 存放OCP原始安装介质的目录
export REDHAT_PULL_SECRET="\${OCP_PATH}/secret/redhat-pull-secret.json"
export OCP_CLUSTER_PATH="/data/ocp-cluster/\${OCP_CLUSTER_ID}"
export IGN_PATH="\${OCP_CLUSTER_PATH}/ignition"            ## 存放Ignition相关文件的目录
export SSH_KEY_PATH="\${OCP_CLUSTER_PATH}/ssh-key"         ## 访问集群节点的私钥文件
export SSH_PRI_FILE="\${SSH_KEY_PATH}/id_rsa"         ## 访问集群节点的私钥文件

export NET_SEGMENT_IP=192.168.203
export NET_SEGMENT_PI=203.168.192

export SUPPORT_IP="\${NET_SEGMENT_IP}.171"                  ## 以下每对都是DNS用的正向IP和反向IP
export SUPPORT_PI="171.\${NET_SEGMENT_PI}"

export DNS_IP="\${NET_SEGMENT_IP}.171"
export DNS_PI="171.\${NET_SEGMENT_PI}"

export NTP_IP="\${NET_SEGMENT_IP}.171"
export NTP_PI="171.\${NET_SEGMENT_PI}"

export YUM_IP="\${NET_SEGMENT_IP}.171"
export YUM_PI="171.\${NET_SEGMENT_PI}"

export NFS_IP="\${NET_SEGMENT_IP}.171"
export NFS_PI="171.\${NET_SEGMENT_PI}"

export LB_IP="\${NET_SEGMENT_IP}.171"
export LB_PI="171.\${NET_SEGMENT_PI}"

export BOOTSTRAP_IP="\${NET_SEGMENT_IP}.191"
export BOOTSTRAP_PI="191.\${NET_SEGMENT_PI}"

export MASTER0_IP="\${NET_SEGMENT_IP}.181"
export MASTER0_PI="181.\${NET_SEGMENT_PI}"

export MASTER1_IP="\${NET_SEGMENT_IP}.182"
export MASTER1_PI="182.\${NET_SEGMENT_PI}"

export MASTER2_IP="\${NET_SEGMENT_IP}.183"
export MASTER2_PI="183.\${NET_SEGMENT_PI}"

export WORKER0_IP="\${NET_SEGMENT_IP}.184"
export WORKER0_PI="184.\${NET_SEGMENT_PI}"

export WORKER1_IP="\${NET_SEGMENT_IP}.185"
export WORKER1_PI="185.\${NET_SEGMENT_PI}"

export GATEWAY_IP="192.168.203.1"
export NETMASK="24"
export NET_IF_NAME="ens192"	              # CoreOS启动时缺省创建的网卡名，该名称须和support节点的网卡名一致。KVM缺省用"ens3"；VMWare缺省用"ens192"；Virtualbox缺省用"enp0s3"

EOF

source ~/.bashrc-${OCP_CLUSTER_ID}

echo =============================================================================================
echo =============== Complete Variables Setting. All Variables Will Be Used Are: =================

echo OCP_VER=${OCP_VER}
echo RHCOS_VER=${RHCOS_VER}
echo OCP_CLUSTER_ID=${OCP_CLUSTER_ID}
echo NODE_LIST=${NODE_LIST}
echo REPLICA_WORKER=${REPLICA_WORKER}
echo REPLICA_MASTER=${REPLICA_MASTER}
echo DOMAIN=${DOMAIN}
echo YUM_DOMAIN=${YUM_DOMAIN}
echo YUM_PATH=${YUM_PATH}
echo OCP_PATH=${OCP_PATH}
echo OCP_CLUSTER_PATH=${OCP_CLUSTER_PATH}
echo IGN_PATH=${IGN_PATH}
echo SSH_KEY_PATH=${SSH_KEY_PATH}
echo SSH_PRI_FILE=${SSH_KEY_PATH}
echo REDHAT_PULL_SECRET=${REDHAT_PULL_SECRET}
echo SUPPORT_IP=${SUPPORT_IP}
echo DNS_IP=${DNS_IP}
echo NTP_IP=${NTP_IP}
echo YUM_IP=${YUM_IP}
echo NFS_IP=${NFS_IP}
echo LB_IP=${LB_IP}
echo BOOTSTRAP_IP=${BOOTSTRAP_IP}
echo MASTER0_IP=${MASTER0_IP}
echo MASTER1_IP=${MASTER1_IP}
echo MASTER2_IP=${MASTER2_IP}
echo WORKER0_IP=${WORKER0_IP}
echo WORKER1_IP=${WORKER1_IP}
echo GATEWAY_IP=${GATEWAY_IP}
echo NETMASK=${NETMASK}
echo NET_IF_NAME=${NET_IF_NAME}


echo =============================================================================================
echo =========================== If error, correct it and re-run me. =============================
echo =============================================================================================
