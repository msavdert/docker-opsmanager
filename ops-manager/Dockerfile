FROM centos/systemd

MAINTAINER Melih Savdert <melihsavdert@gmail.com>

RUN yum -y update && yum -y upgrade

COPY config/mongodb-enterprise.repo /etc/yum.repos.d/mongodb-enterprise.repo

RUN yum install -y mongodb-enterprise wget net-tools; yum clean all;  systemctl enable mongod

RUN mkdir -p /var/lib/mongo/appdb && chown -R mongod:mongod /var/lib/mongo/

# wget https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-3.4.3.402-1.x86_64.rpm
# you may want to replace mongodb-mms-3.4.3.402-1.x86_64.rpm with the corresponding downloaded package name. When
# downloaded, please remove the version number part of the filename (or create a symlink), so the
# resulting file is named mongodb-mms.x86_64.rpm (that way the docker file itself remains version independent).

COPY config/mongod.conf /etc/mongod.conf
ADD mongodb-mms.x86_64.rpm /tmp

RUN rpm -ivh /tmp/mongodb-mms.x86_64.rpm
RUN rm -f /tmp/mongodb-mms.x86_64.rpm

RUN sed -i '/ABS_PATH="$( resolvepath $0 )"/c\SCRIPTPATH=/opt/mongodb/mms/bin/mongodb-mms'"\n"'ABS_PATH="$( resolvepath $SCRIPTPATH )"' /etc/init.d/mongodb-mms

RUN systemctl enable mongodb-mms

RUN mkdir -p /var/lib/mongo/backupDaemon && chown -R mongodb-mms:mongodb-mms /var/lib/mongo/backupDaemon/

#Disable Transparent Huge Pages (THP)
RUN yum install -y tuned; systemctl enable tuned 
ADD config/disable-transparent-hugepages /etc/init.d/disable-transparent-hugepages
RUN chmod 755 /etc/init.d/disable-transparent-hugepages; chkconfig --add disable-transparent-hugepages
ADD config/tuned.conf /etc/tuned/no-thp/tuned.conf
RUN tuned-adm profile no-thp

EXPOSE 8080 27017

# Set the environment variables
ENV HOME /root

# Working directory
WORKDIR /root

CMD ["/usr/sbin/init"]
