echo ================================= Checking Network Interface. ================================
checkNetworkInferface ${NET_IF_NAME}

echo ======================= Checking files will be used during instation. ========================
RESULT=0;
checkFile()
if [ ! -f "$1" ]
then
  echo "ERROR: File doesn't exist: \"$1\""
  RESULT=1
else
  echo "File is right: \"$1\""
fi

checkFile ${YUM_PATH}/rhel-7-server-extras-rpms.tar.gz
checkFile ${YUM_PATH}/rhel-7-server-ose-4.6-rpms.tar.gz
checkFile ${YUM_PATH}/rhel-7-server-rpms.tar.gz
checkFile ${OCP_PATH}/ocp-installer/openshift-install-linux-${OCP_VER}.tar.gz
checkFile ${OCP_PATH}/ocp-client/openshift-client-linux-${OCP_VER}.tar.gz
checkFile ${REDHAT_PULL_SECRET}

if [ $RESULT = 0 ]
then 
  echo ====================== All files are Ready for OpenShift installation. ======================
else
  echo ====================== Fail to check files for OpenShift installation. ======================
fi
