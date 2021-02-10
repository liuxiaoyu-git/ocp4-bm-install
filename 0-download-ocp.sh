export OCP_VER=$(curl -s https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-4.6/release.txt | grep 'Name:' | awk '{print $NF}')
RHCOS_VER=$(curl -s https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.6/latest/sha256sum.txt | grep x86_64-live.x86_64 | awk -F\- '{print $2}' | head -1)
export OCP_PATH=/data/OCP-${OCP_VER}/ocp
export REDHAT_PULL_SECRET=${OCP_PATH}/secret/redhat-pull-secret.json
export PRODUCT_REPO=openshift-release-dev
export RELEASE_NAME=ocp-release

mkdir -p ${OCP_PATH}/{app-image,ocp-client,ocp-image,ocp-installer,rhcos,secret}
read -p "Please input the pull secret string from https://cloud.redhat.com/openshift/install/pull-secret:" PULL_SECRET
echo ${PULL_SECRET} > ${REDHAT_PULL_SECRET}

wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_VER}/openshift-client-linux-${OCP_VER}.tar.gz -P ${OCP_PATH}/ocp-client
tar -xzf ${OCP_PATH}/ocp-client/openshift-client-linux-${OCP_VER}.tar.gz -C /usr/local/sbin/
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_VER}/openshift-install-linux-${OCP_VER}.tar.gz -P ${OCP_PATH}/ocp-installer
wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.6/${RHCOS_VER}/rhcos-${RHCOS_VER}-x86_64-live.x86_64.iso -P ${OCP_PATH}/rhcos

oc adm release mirror -a ${REDHAT_PULL_SECRET} --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_VER}-x86_64 --to-dir=${OCP_PATH}/ocp-image/mirror_${OCP_VER}
tar -zcvf ${OCP_PATH}/ocp-image/ocp-image-${OCP_VER}.tar -C ${OCP_PATH}/ocp-image ./mirror_${OCP_VER}
