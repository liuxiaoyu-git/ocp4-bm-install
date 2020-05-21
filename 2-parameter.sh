\cp ~/.bashrc.origin ~/.bashrc > /dev/null 2>&1 || \cp ~/.bashrc ~/.bashrc.origin
#
cat << EOF >> ~/.bashrc

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

export OCP_VER="4.3.18"
export RHCOS_VER="4.3.8"
export OCP_CLUSTER_ID="ocp4-1"
export DOMAIN="example.internal"
export NODE_LIST="bootstrap master-0 worker-0 worker-1"   ## 主机节点名列表
export YUM_PATH="/data/OCP-${OCP_VER}/yum"                ## 存放yum源的目录
export OCP_PATH="/data/OCP-${OCP_VER}/ocp"                ## 存放OCP原始安装介质的目录
export REGISTRY_PATH="/data/registry"                     ## 容器镜像库存放的根目录
export BOOT_FILE_PATH="/data/boot-files"                  ## 用来存放所有启动CoreOS所需文件的目录
export RHCOS_ISO_PATH="${BOOT_FILE_PATH}/rhcos-iso"       ## 用来存启动CoreOS所需ISO和RAW文件的目录
export BASTION_IP="192.168.1.13"
export SUPPORT_IP="192.168.1.12"
export DNS_IP="192.168.1.12"
export NTP_IP="192.168.1.12"
export YUM_IP="192.168.1.12"
export REGISTRY_IP="192.168.1.12"
export NFS_IP="192.168.1.12"
export LB_IP="192.168.1.12"
export BOOTSTRAP_IP="192.168.1.100"
export MASTER0_IP="192.168.1.101"
export WORKER0_IP="192.168.1.110"
export WORKER1_IP="192.168.1.111"
export YUM_DOMAIN="yum.${DOMAIN}:8080"
export REG_DOMAIN="registry.${DOMAIN}:5000"               ## 容器镜像库的访问域名
export REG_SECRET="${OCP_PATH}/secret/registry-secret.json"	 	## 指定一个文件，用来保存podman登录本地docker registry时所生成的secret，以便以后可免密登录
export REPO_NAME="ocp4/openshift4"                        ## 在Docker Registry中存放OpenShift核心镜像的Repository
export NET_IF_NAME="ens3"	                              ## CoreOS启动时缺省创建的网卡名。注意：不同的IaaS使用的名称不一样，KVM中缺省使用ens3
export GATEWAY="192.168.1.1"                              ## CoreOS启动时使用的GATEWAY
export NETMASK="255.255.255.0"                            ## CoreOS启动时使用的NETMASK
export RHCOS_METAL_URL="http://${YUM_DOMAIN}/rhcos-iso/rhcos-${RHCOS_VER}-x86_64-metal.x86_64.raw.gz"
export IGN_PATH="${BOOT_FILE_PATH}/ignition/ocp4-1"       ## 存放Ignition相关文件的目录
export REPLICA_WORKER="0"                                 ## 在安装阶段，将WORKER的数量设为0
export REPLICA_MASTER="1"                                 ## 本文档的OpenShift集群只有1个master节点
export SSH_PRI_FILE="${IGN_PATH}/ssh-key/id_rsa"          ## Ignition私钥文件名

EOF

echo =============================================================================================
echo =============== Complete Variables Setting. All Variables Will Be Used Are: =================
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
echo REGISTRY_IP=${RHCOS_VER}
echo NFS_IP=${NFS_IP}
echo LB_IP=${LB_IP}
echo BOOTSTRAP_IP=${BOOTSTRAP_IP}
echo MASTER0_IP=${MASTER0_IP}
echo WORKER0_IP=${WORKER0_IP}
echo WORKER1_IP=${WORKER1_IP}
echo REG_SECRET=${REG_SECRET}
echo SSH_PRI_FILE=${SSH_PRI_FILE}
echo NET_IF_NAME=${NET_IF_NAME}
echo GATEWAY=${GATEWAY}
echo RHCOS_METAL_URL=${RHCOS_METAL_URL}
echo IGN_PATH=${IGN_PATH}
echo REPLICA_WORKER=${REPLICA_WORKER}
echo REPLICA_MASTER=${REPLICA_MASTER}
echo ========================= Please Run Next Line to Make Them Works. ==========================
echo "====================================== source ~/.bashrc ======================================"
