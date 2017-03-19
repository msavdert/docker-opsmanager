FROM centos/systemd

MAINTAINER Melih Savdert <melihsavdert@gmail.com>

RUN yum -y update && yum -y upgrade
# Install MongoDB Enterprise Version dependencies - openssl - tuned
RUN yum install -y tuned sudo openssl cyrus-sasl cyrus-sasl-plain cyrus-sasl-gssapi krb5-libs lm_sensors-libs net-snmp-agent-libs net-snmp openssl rpm-libs tcp_wrappers-libs libcurl; systemctl enable tuned

#RUN cd /tmp \
#	&& curl -OL https://cloud.mongodb.com/download/agent/automation/mongodb-mms-automation-agent-manager-latest.x86_64.rhel7.rpm \
#	&& rpm -U mongodb-mms-automation-agent-manager-latest.x86_64.rhel7.rpm \
#        && rm -f mongodb-mms-automation-agent-manager-latest.x86_64.rhel7.rpm

#Disable Transparent Huge Pages (THP)
ADD config/disable-transparent-hugepages /etc/init.d/disable-transparent-hugepages
RUN chmod 755 /etc/init.d/disable-transparent-hugepages; chkconfig --add disable-transparent-hugepages
ADD config/tuned.conf /etc/tuned/no-thp/tuned.conf
RUN tuned-adm profile no-thp

# Create mongodb.pem file for SSL certificate
RUN cd /etc/ssl/; openssl req -newkey rsa:2048 -new -x509 -days 365 -nodes -out mongodb-cert.crt -keyout mongodb-cert.key -subj "/C=TR/ST=Turkey/L=Istanbul/O=.../OU=.../CN=.../emailAddress=..."; cat mongodb-cert.key mongodb-cert.crt > mongodb.pem

#RUN mkdir -p /var/lib/mongo && chown mongod:mongod /var/lib/mongo

EXPOSE 27000-27020

# Set the environment variables
ENV HOME /root

# Working directory
WORKDIR /root

CMD ["/usr/sbin/init"]
