#!/bin/bash
set -e

# Install MySQL 8 on Amazon Linux 2
yum update -y
amazon-linux-extras enable mysql8.0
yum clean metadata
yum install -y mysql-server

# Start and enable
systemctl enable --now mysqld

# Wait for mysql to be ready
sleep 10

# Secure install minimal (set root password to random, but we will create dms user)
MYSQL_ROOT_PWD="ChangeMeRoot123!" # replace or rotate via Secrets Manager later
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$${MYSQL_ROOT_PWD}';
FLUSH PRIVILEGES;
EOF

# Configure binlog and server-id for replication
cat >> /etc/my.cnf <<'EOF'
[mysqld]
server-id=100
log_bin=mysql-bin
binlog_format=row
expire_logs_days=7
max_binlog_size=100M
EOF

systemctl restart mysqld
sleep 5

# Create DMS user with required privileges
DMS_USER="dms_user"
DMS_PASS="ChangeMeDms123!" # replace with Secrets Manager value
mysql -u root -p"$${MYSQL_ROOT_PWD}" <<EOF
CREATE USER IF NOT EXISTS '$${DMS_USER}'@'%' IDENTIFIED BY '$${DMS_PASS}';
GRANT REPLICATION SLAVE, REPLICATION CLIENT, SELECT, SHOW VIEW, EVENT, TRIGGER ON *.* TO '$${DMS_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Tag instance for identification
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

aws ec2 create-tags --resources $${INSTANCE_ID} --tags Key=Name,Value=onprem-mysql --region ${AWS_REGION}
