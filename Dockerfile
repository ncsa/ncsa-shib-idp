FROM i2incommon/shib-idp:latest

# Need myproxy-logon and openssl for crl cronjob.
RUN yum -y update && yum -y install myproxy openssl && yum -y clean all

COPY config/etc /etc
COPY config/shib-idp /opt/shibboleth-idp
COPY config/tomcat /usr/local/tomcat
