#!/bin/bash
echo "配置yum源"
# 配置本地源文件
echo '[appstream]
name=Redhat 8 appstream
baseurl=ftp://192.168.10.10/AppStream
gpgcheck=0
enabled=1

[baseos]
name=Redhat 8 BaseOS
baseurl=ftp://192.168.10.10/BaseOS
enabled=1
gpgcheck=0' > /etc/yum.repos.d/redhat-local.repo
# 下载软件包
echo "下载wget命令"
yum -y install wget
echo "下载软件包"
# 下载 MySQL 安装包
echo "正在下载 MySQL 安装包..."
wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.40-linux-glibc2.28-x86_64.tar
# 解压安装包并移动到指定目录
echo "正在解压安装包并移动到指定目录..."
tar xf mysql-8.0.40-linux-glibc2.28-x86_64.tar -C /usr/local/
tar xf /usr/local/mysql-8.0.40-linux-glibc2.28-x86_64.tar.xz -C /usr/local/
mv /usr/local/mysql-8.0.40-linux-glibc2.28-x86_64 /usr/local/mysql

# 安装依赖
echo "正在安装依赖..."
mount /dev/sr0 /mnt
yum install libaio ncurses-compat-libs -y

# 创建数据目录
echo "正在创建数据目录..."
mkdir -p /usr/local/mysql/3306

# 创建配置文件
echo "正在创建配置文件..."
cat > /usr/local/mysql/3306/my.cnf <<EOF
[mysqld]
user=mysql
basedir=/usr/local/mysql/
datadir=/usr/local/mysql/3306/data
pid-file=/usr/local/mysql/3306/mysqld.pid
socket=/usr/local/mysql/3306/mysql.sock
port=3306
EOF

# 创建 MySQL 用户和组
echo "正在创建 MySQL 用户和组..."
groupadd mysql
useradd -r -g mysql -s /bin/false mysql

# 修改目录权限
echo "正在修改目录权限..."
chown mysql:mysql -R /usr/local/mysql/3306

# 初始化数据库
echo "正在初始化数据库..."
/usr/local/mysql/bin/mysqld --initialize --basedir=/usr/local/mysql/ --datadir=/usr/local/mysql/3306/data --user=mysql 2>&1 | tee /tmp/mysql_init.log

echo "正在提取临时密码..."
temp_password=$(grep 'temporary password' /tmp/mysql_init.log | awk '{print $NF}')

# 启动 MySQL 服务
echo "正在启动 MySQL 服务..."
/usr/local/mysql/bin/mysqld_safe --defaults-file=/usr/local/mysql/3306/my.cnf --user=mysql &
sleep 5

# 创建软链接
echo "正在创建软链接..."
ln -s /usr/local/mysql/3306/mysql.sock /tmp/mysql.sock

# 配置环境变量
echo "正在配置环境变量..."
echo 'export PATH=$PATH:/usr/local/mysql/bin' >> /etc/profile
source /etc/profile

# 登录 MySQL 并修改 root 密码
echo "正在登录 MySQL 并修改 root 密码..."
/usr/local/mysql/bin/mysql -u root -p"$temp_password" --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'shibingyv';"

# 完成
echo "MySQL 安装和配置完成。"
