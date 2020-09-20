export OCP_VER=$(curl -s https://mirror.openshift.com/pub/openshift-v4/clients/ocp/candidate-4.5/release.txt | \grep 'Name:' | awk '{print $NF}')
export OCP_PATH=/data/OCP-${OCP_VER}/ocp
mkdir -p ${OCP_PATH}/{app-image,ocp-client,ocp-image,ocp-installer,rhcos,secret}
export REDHAT_SECRET=${OCP_PATH}/secret/redhat-secret.json
export PRODUCT_REPO=openshift-release-dev
export RELEASE_NAME=ocp-release
echo "Please download https://cloud.redhat.com/openshift/install/pull-secret to ${OCP_PATH}/secret/redhat-secret.json"
