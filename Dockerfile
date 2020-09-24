FROM tier/shib-idp:latest

# Need myproxy-logon for crl cronjob.
RUN yum -y update && yum -y install myproxy && yum -y clean all

COPY config/etc /etc
COPY config/shib-idp /opt/shibboleth-idp
COPY config/tomcat /usr/local/tomcat
