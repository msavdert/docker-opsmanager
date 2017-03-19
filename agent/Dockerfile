FROM centos/systemd

MAINTAINER Melih Savdert <melihsavdert@gmail.com>

RUN yum -y update && yum -y upgrade
RUN yum install -y tuned sudo; systemctl enable tuned


RUN cd /tmp \
	&& curl -OL https://cloud.mongodb.com/download/agent/automation/mongodb-mms-automation-agent-manager-latest.x86_64.rhel7.rpm \
	&& rpm -U mongodb-mms-automation-agent-manager-latest.x86_64.rhel7.rpm \
        && rm -f mongodb-mms-automation-agent-manager-latest.x86_64.rhel7.rpm

#Disable Transparent Huge Pages (THP)
ADD config/disable-transparent-hugepages /etc/init.d/disable-transparent-hugepages
RUN chmod 755 /etc/init.d/disable-transparent-hugepages; chkconfig --add disable-transparent-hugepages
ADD config/tuned.conf /etc/tuned/no-thp/tuned.conf
RUN tuned-adm profile no-thp
	
RUN mkdir -p /var/lib/mongo && chown mongod:mongod /var/lib/mongo

EXPOSE 27000-27020

# Set the environment variables
ENV HOME /root

# Working directory
WORKDIR /root

CMD ["/usr/sbin/init"]
