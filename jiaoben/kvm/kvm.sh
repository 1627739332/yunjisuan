#!/bin/bash

# 检查ISO文件是否存在
check_iso() {
    if [ ! -f "${ISO_PATH}" ]; then
        echo "错误：ISO文件 ${ISO_PATH} 不存在！"
        exit 1
    fi
}

# 检查Kickstart文件是否存在
check_kickstart() {
    if [ ! -f "${KS_PATH}" ]; then
        echo "错误：Kickstart文件 ${KS_PATH} 不存在！"
        exit 1
    fi
}

# 主程序
read -p "请输入虚拟机名称 (默认: vm_name): " VM_NAME
VM_NAME=${VM_NAME:-vm_name}

read -p "请输入内存大小 MB (默认: 4096): " RAM
RAM=${RAM:-4096}

read -p "请输入虚拟 CPU 数量 (默认: 2): " VCPUS
VCPUS=${VCPUS:-2}

read -p "请输入磁盘大小 GB (默认: 20): " DISK_SIZE
DISK_SIZE=${DISK_SIZE:-20}

DEFAULT_DISK_PATH="/opt/pxe/vm/${VM_NAME}.qcow2"
read -p "请输入磁盘路径 (默认: ${DEFAULT_DISK_PATH}): " DISK_PATH
DISK_PATH=${DISK_PATH:-$DEFAULT_DISK_PATH}

DEFAULT_ISO_PATH="/opt/pxe/iso/rhel-8.8-x86_64-dvd.iso"
read -p "请输入ISO镜像路径 (默认: ${DEFAULT_ISO_PATH}): " ISO_PATH
ISO_PATH=${ISO_PATH:-$DEFAULT_ISO_PATH}
check_iso

read -p "请输入 Kickstart 文件路径 (默认: /opt/pxe/ks.cfg): " KS_PATH
KS_PATH=${KS_PATH:-/opt/pxe/ks.cfg}
check_kickstart

read -p "请输入操作系统变体 (默认: rhel8.8): " OS_VARIANT
OS_VARIANT=${OS_VARIANT:-rhel8.8}

# 执行创建命令
echo "正在创建虚拟机..."
virt-install \
--name="${VM_NAME}" \
--ram="${RAM}" \
--vcpus="${VCPUS}" \
--disk path="${DISK_PATH}",size="${DISK_SIZE}",format=qcow2 \
--location="${ISO_PATH}" \
--initrd-inject="${KS_PATH}" \
--extra-args="inst.ks=file:/ks.cfg console=ttyS0" \
--network network=default,model=virtio \
--graphics none \
--os-variant="${OS_VARIANT}" \
--wait -1
# --noreboot

echo "虚拟机 ${VM_NAME} 创建完成！建议使用以下命令管理："
echo "启动虚拟机：virsh start ${VM_NAME}"
echo "查看控制台：virsh console ${VM_NAME}"
