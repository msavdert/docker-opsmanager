FROM centos/systemd

MAINTAINER Melih Savdert <melihsavdert@gmail.com>

RUN yum -y update && yum -y upgrade

#ADD mongodb-mms-automation-agent-manager-latest.x86_64.rhel7.rpm /tmp
#RUN rpm -U /tmp/mongodb-mms-automation-agent-manager-latest.x86_64.rhel7.rpm
	
#RUN mkdir -p /var/lib/mongo && chown mongod:mongod /var/lib/mongo
#RUN systemctl enable mongodb-mms-automation-agent.service	

EXPOSE 27000-27020

# Set the environment variables
ENV HOME /root

# Working directory
WORKDIR /root

CMD ["/usr/sbin/init"]
