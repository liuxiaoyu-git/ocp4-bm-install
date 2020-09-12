#----------------------------------------------------------------------------
echo "STEP：Prepare Boot Config Files"

rm -rf ${RHCOS_ISO_PATH}
mkdir -p ${RHCOS_ISO_PATH}
cp ${OCP_PATH}/rhcos/rhcos-${RHCOS_VER}-x86_64-metal.x86_64.raw.gz ${RHCOS_ISO_PATH}/
rm -rf ${BOOT_FILE_PATH}/{rhcos-temp,rhcos-mnt}
mkdir -p ${BOOT_FILE_PATH}/{rhcos-temp,rhcos-mnt}
rm -rf ${RHCOS_ISO_PATH}/${OCP_CLUSTER_ID}
mkdir -p ${RHCOS_ISO_PATH}/${OCP_CLUSTER_ID}
mount -o loop -t iso9660 ${OCP_PATH}/rhcos/rhcos-${RHCOS_VER}-x86_64-installer.x86_64.iso ${BOOT_FILE_PATH}/rhcos-mnt
#
modify_cfg(){
  for file in "${BOOT_FILE_PATH}/rhcos-mnt/EFI/redhat/grub.cfg" "${BOOT_FILE_PATH}/rhcos-mnt/isolinux/isolinux.cfg"; do
    IGN_FILE_URL=http://${YUM_DOMAIN}/ignition/${OCP_CLUSTER_ID}/${1}.ign
    sed -e '/coreos.inst=yes/s|$| coreos.inst.install_dev=sda coreos.inst.image_url='"${RHCOS_METAL_URL}"' coreos.inst.ignition_url='"${IGN_FILE_URL}"' ip='"${IP}"'::'"${GATEWAY}"':'"${NETMASK}"':'"${FQDN}"':'"${NET_IF_NAME}"':none nameserver='"${DNS_IP}"'|' ${file} > ${RHCOS_ISO_PATH}/${OCP_CLUSTER_ID}/${NODE_NAME}_${file##*/}
    sed -i -e 's/default vesamenu.c32/default linux/g' -e 's/timeout 600/timeout 15/g' ${RHCOS_ISO_PATH}/${OCP_CLUSTER_ID}/${NODE_NAME}_${file##*/}
  done
}
#创建BOOTSTRAP启动定制文件
NODE_NAME="bootstrap"
NODE_TYPE="bootstrap"
IP=${BOOTSTRAP_IP}
FQDN="${NODE_NAME}.${OCP_CLUSTER_ID}.${DOMAIN}"
modify_cfg ${NODE_TYPE}

#创建master-0启动定制文件
NODE_NAME="master-0"
NODE_TYPE="master"
IP=${MASTER0_IP}
FQDN="${NODE_NAME}.${OCP_CLUSTER_ID}.${DOMAIN}"
modify_cfg ${NODE_TYPE}

#创建master-1启动定制文件
NODE_NAME="master-1"
NODE_TYPE="master"
IP=${MASTER1_IP}
FQDN="${NODE_NAME}.${OCP_CLUSTER_ID}.${DOMAIN}"
modify_cfg ${NODE_TYPE}

#创建master-2启动定制文件
NODE_NAME="master-2"
NODE_TYPE="master"
IP=${MASTER2_IP}
FQDN="${NODE_NAME}.${OCP_CLUSTER_ID}.${DOMAIN}"
modify_cfg ${NODE_TYPE}

#创建worker-0启动定制文件
NODE_NAME="worker-0"
NODE_TYPE="worker"
IP=${WORKER0_IP}
FQDN="${NODE_NAME}.${OCP_CLUSTER_ID}.${DOMAIN}"
modify_cfg ${NODE_TYPE}

#创建worker-1启动定制文件
NODE_NAME="worker-1"
NODE_TYPE="worker"
IP=${WORKER1_IP}
FQDN="${NODE_NAME}.${OCP_CLUSTER_ID}.${DOMAIN}"
modify_cfg ${NODE_TYPE}
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
yum -y install genisoimage 
export VOL_ID=$(isoinfo -d -i ${OCP_PATH}/rhcos/rhcos-${RHCOS_VER}-x86_64-installer.x86_64.iso |awk '/Volume set id/ {print $4}')
\cp -pRf ${BOOT_FILE_PATH}/rhcos-mnt/* ${BOOT_FILE_PATH}/rhcos-temp/ > /dev/null 2>&1
for node in ${NODE_LIST}; do
  for file in "${BOOT_FILE_PATH}/rhcos-temp/EFI/redhat/grub.cfg" "${BOOT_FILE_PATH}/rhcos-temp/isolinux/isolinux.cfg"; do
    /bin/cp -f ${RHCOS_ISO_PATH}/${OCP_CLUSTER_ID}/${node}_${file##*/} ${file}
  done
  genisoimage -U -A 'RHCOS-x86_64' -V 'RHCOS-x86_64' -volset ${VOL_ID} -J -joliet-long -r -v -T \
            -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table \
            -eltorito-alt-boot -efi-boot images/efiboot.img -no-emul-boot \
            -o ${RHCOS_ISO_PATH}/${OCP_CLUSTER_ID}/${node}.iso ${BOOT_FILE_PATH}/rhcos-temp
done
#
umount ${BOOT_FILE_PATH}/rhcos-mnt

echo =============================================================================================
echo ================================= Bootable Files Generated in ===============================
ls -al ${RHCOS_ISO_PATH}/${OCP_CLUSTER_ID}/*
