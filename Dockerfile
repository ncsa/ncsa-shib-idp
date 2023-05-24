FROM i2incommon/shib-idp:latest

COPY config/shib-idp /opt/shibboleth-idp
COPY config/tomcat /usr/local/tomcat
COPY VERSION /usr/local/tomcat

RUN /opt/shibboleth-idp/bin/plugin.sh --noPrompt -i \
        https://shibboleth.net/downloads/identity-provider/plugins/oidc-common/2.2.0/oidc-common-dist-2.2.0.tar.gz \
    && /opt/shibboleth-idp/bin/plugin.sh --noPrompt -i \
        https://shibboleth.net/downloads/identity-provider/plugins/duo-oidc/1.4.0/idp-plugin-duo-nimbus-dist-1.4.0.tar.gz \
    && rm -f /opt/shibboleth-idp/conf/authn/duo-oidc.properties
