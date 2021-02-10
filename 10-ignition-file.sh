echo "STEP：Create ssh-key for Accessing CoreOS"

rm -rf ${SSH_KEY_PATH}
mkdir -p ${SSH_KEY_PATH}
ssh-keygen -N '' -f ${SSH_PRI_FILE}
export PULL_SECRET="$(cat ${REDHAT_PULL_SECRET})"
export SSH_PUB_STR="$(cat ${SSH_KEY_PATH}/id_rsa.pub)"     ## Ignition私钥文件名公钥文件内容

echo "STEP：Create CoreOS ignition files"
rm -rf ${IGN_PATH}
mkdir -p ${IGN_PATH}

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
  - ${REGISTRY_DOMAIN}/${REPO_NAME}
  source: quay.io/openshift-release-dev/ocp-release
- mirrors:
  - ${REGISTRY_DOMAIN}/${REPO_NAME}
  source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
EOF
#
\cp ${REGISTRY_PATH}/certs/registry.crt ${IGN_PATH}/ > /dev/null 2>&1
sed -i -e 's/^/  /' ${IGN_PATH}/registry.crt
echo "additionalTrustBundle: |" >> ${IGN_PATH}/install-config.yaml
cat ${IGN_PATH}/registry.crt >> ${IGN_PATH}/install-config.yaml

cp ${IGN_PATH}/install-config.yaml{,.`date +%Y%m%d%H%M`.bak}
tar -xzf ${OCP_PATH}/ocp-installer/openshift-install-linux-${OCP_VER}.tar.gz -C /usr/local/sbin/
openshift-install create manifests --dir ${IGN_PATH}
sed -i 's/mastersSchedulable: true/mastersSchedulable: false/g' ${IGN_PATH}/manifests/cluster-scheduler-02-config.yml

#================
export NTP_CONF=$(cat << EOF | base64 -w 0
server ntp.${DOMAIN} iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
logdir /var/log/chrony
EOF)

cat << EOF > ${IGN_PATH}/openshift/99_masters-chrony-configuration.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: masters-chrony-configuration
spec:
  config:
    ignition:
      config: {}
      security:
        tls: {}
      timeouts: {}
      version: 3.1.0
    networkd: {}
    passwd: {}
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,${NTP_CONF}
        mode: 420
        overwrite: true
        path: /etc/chrony.conf
  osImageURL: ""
EOF

cat << EOF > ${IGN_PATH}/openshift/99_workers-chrony-configuration.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: workers-chrony-configuration
spec:
  config:
    ignition:
      config: {}
      security:
        tls: {}
      timeouts: {}
      version: 3.1.0
    networkd: {}
    passwd: {}
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,${NTP_CONF}
        mode: 420
        overwrite: true
        path: /etc/chrony.conf
  osImageURL: ""
EOF


openshift-install create ignition-configs --dir ${IGN_PATH}/

echo =============================================================================================
echo =============================== All Generated Ignition Files ================================
ls -al ${IGN_PATH}/*.ign 
