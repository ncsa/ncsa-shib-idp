FROM i2incommon/shib-idp:latest5

COPY config/shib-idp /opt/shibboleth-idp
COPY config/tomcat /usr/local/tomcat
COPY VERSION /usr/local/tomcat

RUN /opt/shibboleth-idp/bin/plugin.sh -I net.shibboleth.oidc.common \
    && /opt/shibboleth-idp/bin/plugin.sh -I net.shibboleth.idp.plugin.authn.duo.nimbus \
    && rm -f /opt/shibboleth-idp/conf/authn/duo-oidc.properties

RUN /opt/shibboleth-idp/bin/module.sh -t idp.intercept.ContextCheck \
    || /opt/shibboleth-idp/bin/module.sh -e idp.intercept.ContextCheck
