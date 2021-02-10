read -p "Please input the OpenShift Version (for example 4.5.12):" OCP_VER
read -s -p "Please input the Red Hat Subscribe UserName:" SUB_USER
echo -e "\r"
read -s -p "Please input the Red Hat Subscribe Password:" SUB_PASSWD
echo -e "\r"

export YUM_PATH=/data/OCP-${OCP_VER}/yum
mkdir -p ${YUM_PATH}

#rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

#subscription-manager register --force --user ${SUB_USER} --password ${SUB_PASSWD}
#subscription-manager refresh
subscription-manager list --available --matches '*OpenShift Container Platform,*' | grep "Pool ID"
read -p "Please input the Pool ID you got:" POOL_ID
subscription-manager attach --pool=${POOL_ID}
subscription-manager repos --disable="*"
subscription-manager repos \
    --enable="rhel-7-server-rpms" \
    --enable="rhel-7-server-extras-rpms" \
    --enable="rhel-7-server-ose-4.6-rpms"

yum -y install yum-utils createrepo
for repo in $(subscription-manager repos --list-enabled |grep "Repo ID" |awk '{print $3}'); do
    reposync --gpgcheck -lmn --repoid=${repo} --download_path=${YUM_PATH}
    createrepo -v ${YUM_PATH}/${repo} -o ${YUM_PATH}/${repo} 
done

for dir in $(ls --indicator-style=none ${YUM_PATH}/); do
    tar -zcvf ${YUM_PATH}/${dir}.tar.gz ${dir}; 
done

rm -rf $(ls ${YUM_PATH} | egrep -v gz)
subscription-manager unregister
