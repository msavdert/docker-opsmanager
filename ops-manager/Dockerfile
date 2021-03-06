FROM centos/systemd

MAINTAINER Melih Savdert <melihsavdert@gmail.com>

###################################################################################
##  System Updates
###################################################################################
RUN yum -y update && yum -y upgrade

# Configure the yum package management system to install the latest stable release of MongoDB.
COPY config/mongodb-enterprise.repo /etc/yum.repos.d/mongodb-enterprise.repo

# Install MongoDB and enable MongoDB service.
RUN yum install -y mongodb-enterprise wget sudo net-tools; yum clean all;  systemctl enable mongod

#Create the data directory for the Ops Manager Application Database.
RUN mkdir -p /var/lib/mongo/appdb && chown -R mongod:mongod /var/lib/mongo/

#Create the backup directory.
RUN mkdir -p /var/lib/mongo/backup && chown -R mongod:mongod /var/lib/mongo/

# wget https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-3.4.3.402-1.x86_64.rpm
# you may want to replace mongodb-mms-3.4.3.402-1.x86_64.rpm with the corresponding downloaded package name. When
# downloaded, please remove the version number part of the filename (or create a symlink), so the
# resulting file is named mongodb-mms.x86_64.rpm (that way the docker file itself remains version independent).

COPY config/mongod.conf /etc/mongod.conf
ADD mongodb-mms.x86_64.rpm /tmp

# Install Ops Manager and remove installed rpm package
RUN rpm -ivh /tmp/mongodb-mms.x86_64.rpm
RUN rm -f /tmp/mongodb-mms.x86_64.rpm

# Only if you installed to RHEL 7.1 or 7.2, replace symlinks with scripts.
RUN sed -i '/ABS_PATH="$( resolvepath $0 )"/c\SCRIPTPATH=/opt/mongodb/mms/bin/mongodb-mms'"\n"'ABS_PATH="$( resolvepath $SCRIPTPATH )"' /etc/init.d/mongodb-mms

# Enable Ops Manager service.
RUN systemctl enable mongodb-mms

###################################################################################
##  Running two MongoDB instances on one server
###################################################################################
# Make a copy of the MongoDB config file for the Backup Database
RUN cp /etc/mongod.conf /etc/mongodbackup.conf

# Edit Backup Database config file to have different paths and port
RUN sed -i -- 's/27017/27018/g;s/appdb/backup/g;s/mongod.log/mongodbackup.log/g;s#mongodb/mongod.pid#mongodbackup/mongodbackup.pid#g' /etc/mongodbackup.conf

# Edit Backup Database config file to change storage engine mmapv1
RUN sed -i -- 's/.*mmapv1.*/  engine: mmapv1/' /etc/mongodbackup.conf

# Copy the mongod binary for the Backup Database
RUN cp /usr/bin/mongod /usr/bin/mongod2

# Copy the init.d script and make some changes
RUN cp /usr/lib/systemd/system/mongod.service /usr/lib/systemd/system/mongodbackup.service

# Edit the mongodbackup.service script
RUN sed -i -- 's/mongodb/mongodbackup/g;s/mongod.pid/mongodbackup.pid/g;s/mongod.conf/mongodbackup.conf/g;s#/usr/bin/mongod#/usr/bin/mongod2#g' /usr/lib/systemd/system/mongodbackup.service

# Enable Backup Database service
RUN systemctl enable mongodbackup

# Create a directory to store the head databases.
RUN mkdir -p /var/lib/mongo/backupDaemon && chown -R mongodb-mms:mongodb-mms /var/lib/mongo/backupDaemon/

###################################################################################
##  Disable Transparent Huge Pages (THP)
###################################################################################
RUN yum install -y tuned openssl; systemctl enable tuned 
ADD config/disable-transparent-hugepages /etc/init.d/disable-transparent-hugepages
RUN chmod 755 /etc/init.d/disable-transparent-hugepages; chkconfig --add disable-transparent-hugepages
ADD config/tuned.conf /etc/tuned/no-thp/tuned.conf
RUN tuned-adm profile no-thp

###################################################################################
##  Create SLL certificates
###################################################################################
# Create mongodb.pem file for SSL certificate
RUN cd /etc/ssl/; openssl req -newkey rsa:2048 -new -passout pass:"oracle" -x509 -days 365 -nodes -out mongodb-cert.crt -keyout mongodb-cert.key -subj "/C=TR/ST=Turkey/L=Istanbul/O=.../OU=.../CN=.../emailAddress=..."; cat mongodb-cert.key mongodb-cert.crt > mongodb.pem

# Specify the settings the Automation Agent uses when communicating with Ops Manager using SSL
RUN cd /etc/ssl/;openssl req -newkey rsa:2048 -new -passout pass:"oracle" -x509 -nodes -out mms-ssl.crt -keyout mms-ssl.key -subj "/C=TR/ST=Turkey/L=Istanbul/O=.../OU=.../CN=opsmanager/emailAddress=..."; cat mms-ssl.key mms-ssl.crt > mms-ssl-unified.crt

###################################################################################
##  SSH Shared Keys
###################################################################################
# Install SSH
RUN yum install -y openssh openssh-server openssh-clients openssl-libs; cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig; systemctl enable sshd.service

# Create SSH shared key directory
RUN ["mkdir", "-p", "-m", "0700", "/root/.ssh/"]

# Generate SSH shared keys
RUN ssh-keygen -q -C '' -N '' -f /root/.ssh/id_rsa

# Create the authorized_keys file
RUN cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys

# Change permissions of the authorized_keys file
RUN ["chmod", "0640", "/root/.ssh/authorized_keys"]

# ** WARNING: soft rlimits too low.
RUN echo 'mongod     soft    nproc     64000' > /etc/security/limits.d/90-nproc.conf
RUN echo 'mongod2     soft    nproc     64000' >> /etc/security/limits.d/90-nproc.conf

EXPOSE 8080 8443 27017 27018

# Set the environment variables
ENV HOME /root

# Working directory
WORKDIR /root

ADD config/authentication.sh /tmp
RUN ["chmod", "+x", "/tmp/authentication.sh"]
CMD ["/usr/sbin/init"]
