wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_VER}/openshift-install-linux-${OCP_VER}.tar.gz -P ${OCP_PATH}/ocp-installer
tar -xzf ${OCP_PATH}/ocp-client/openshift-client-linux-${OCP_VER}.tar.gz -C /usr/local/sbin/
oc adm release mirror -a ${REDHAT_SECRET} --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_VER}-x86_64 --to-dir=${OCP_PATH}/ocp-image/mirror_${OCP_VER}
wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.5/${RHCOS_VER}/rhcos-${RHCOS_VER}-x86_64-installer.x86_64.iso -P ${OCP_PATH}/rhcos
wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.5/${RHCOS_VER}/rhcos-${RHCOS_VER}-x86_64-metal.x86_64.raw.gz -P ${OCP_PATH}/rhcos
