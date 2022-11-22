FROM i2incommon/shib-idp:latest

# Need myproxy-logon and openssl for crl cronjob.
RUN yum -y update && yum -y install myproxy openssl && yum -y clean all

COPY config/etc /etc
COPY config/shib-idp /opt/shibboleth-idp
COPY config/tomcat /usr/local/tomcat

RUN /opt/shibboleth-idp/bin/plugin.sh --noPrompt -i \
        https://shibboleth.net/downloads/identity-provider/plugins/oidc-common/2.1.0/oidc-common-dist-2.1.0.tar.gz \
    && /opt/shibboleth-idp/bin/plugin.sh --noPrompt -i \
        https://shibboleth.net/downloads/identity-provider/plugins/duo-oidc/1.3.0/idp-plugin-duo-nimbus-dist-1.3.0.tar.gz \
    && rm -f /opt/shibboleth-idp/conf/authn/duo-oidc.properties
