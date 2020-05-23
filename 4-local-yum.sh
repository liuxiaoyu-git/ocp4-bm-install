echo "STEP：Create Local YUM Repo"

for file in $(ls ${YUM_PATH}/*.tar.gz); do 
  tar -zxvf ${file} -C ${YUM_PATH}/              # 至少需要这些文件 rhel-7-server-rpms.tar.gz、rhel-7-server-ose-4.3-rpms.tar.gz、rhel-7-server-extras-rpms.tar.gz
done
#
cat << EOF > /etc/yum.repos.d/base.repo
[rhel]
name=rhel
baseurl=file://${YUM_PATH}/rhel-7-server-rpms
enabled=1
gpgcheck=0

[ose]
name=ose
baseurl=file://${YUM_PATH}/rhel-7-server-ose-4.3-rpms
enabled=1
gpgcheck=0

[extras]
name=extras
baseurl=file://${YUM_PATH}/rhel-7-server-extras-rpms
enabled=1
gpgcheck=0

EOF
#
rm -rf ${YUM_PATH}/*.tar.gz
yum -y install createrepo
for dir in $(ls --indicator-style=none $YUM_PATH); do 
  createrepo ${YUM_PATH}/${dir}/
done

echo =============================================================================================
echo ================================= Complete Local Yum Config =================================
echo =============== At Least Yum Should Includes 3 Repositories: rhel, ose, extra ===============
yum repolist