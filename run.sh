sudo podman run -d --name shib-idp -h idp.ncsa.illinois.edu \
  -p 80:80 -p 443:443 --restart always \
  --dns 141.142.2.2 --dns 141.142.230.144 \
  --ip 10.88.0.2 \
  -v /opt/ncsa-shib-idp/config/shib-idp/conf/ldap.properties:/opt/shibboleth-idp/conf/ldap.properties \
  -v /opt/ncsa-shib-idp/config/shib-idp/conf/attribute-resolver.xml:/opt/shibboleth-idp/conf/attribute-resolver.xml \
  -v /opt/ncsa-shib-idp/config/tomcat/server.xml:/usr/local/tomcat/conf/server.xml \
  -v /opt/ncsa-shib-idp/credentials/shib-idp:/opt/shibboleth-idp/credentials \
  -v /opt/ncsa-shib-idp/credentials/tomcat:/opt/certs \
  --log-driver=journald \
ghcr.io/ncsa/ncsa-shib-idp:latest
