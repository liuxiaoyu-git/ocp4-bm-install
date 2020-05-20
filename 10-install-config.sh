echo "STEP：Create ssh-key for Accessing CoreOS"

rm -rf ${IGN_PATH}/ssh-key
mkdir -p ${IGN_PATH}/ssh-key
ssh-keygen -N '' -f ${IGN_PATH}/ssh-key/id_rsa
export PULL_SECRET="$(jq -c . ${REG_SECRET})"
export SSH_PUB_STR="$(cat ${IGN_PATH}/ssh-key/id_rsa.pub)"     ## Ignition私钥文件名公钥文件内容
#
cat << EOF > ${IGN_PATH}/install-config.yaml
apiVersion: v1
baseDomain: ${DOMAIN}
compute:
- hyperthreading: Enabled
  name: worker
  replicas: ${REPLICA_WORKER}
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: ${REPLICA_MASTER}
metadata:
  name: ${OCP_CLUSTER_ID}
networking:
  clusterNetworks:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
platform:
  none: {}
fips: false
pullSecret: '${PULL_SECRET}'
sshKey: '${SSH_PUB_STR}'
imageContentSources: 
- mirrors:
  - ${REG_DOMAIN}/${REPO_NAME}
  source: quay.io/openshift-release-dev/ocp-release
- mirrors:
  - ${REG_DOMAIN}/${REPO_NAME}
  source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
EOF
#
\cp /etc/pki/ca-trust/source/anchors/registry.crt ${IGN_PATH}/ > /dev/null 2>&1
sed -i -e 's/^/  /' ${IGN_PATH}/registry.crt
echo "additionalTrustBundle: |" >> ${IGN_PATH}/install-config.yaml
cat ${IGN_PATH}/registry.crt >> ${IGN_PATH}/install-config.yaml
cp ${IGN_PATH}/install-config.yaml{,.`date '+%s'`.bak}
tar -xzf ${OCP_PATH}/ocp-installer/openshift-install-linux-${OCP_VER}.tar.gz -C /usr/local/sbin/
openshift-install create manifests --dir ${IGN_PATH}
sed -i 's/mastersSchedulable: true/mastersSchedulable: false/g' ${IGN_PATH}/manifests/cluster-scheduler-02-config.yml
openshift-install create ignition-configs --dir ${IGN_PATH}/
chmod 604 ${IGN_PATH}/*.ign 

echo =============================================================================================
echo =============================== All Generated Ignition Files ================================
ls -al ${IGN_PATH}/*.ign 