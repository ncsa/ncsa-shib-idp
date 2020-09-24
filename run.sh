docker run -d --name idp-ncsa -h idp.ncsa.illinois.edu \
  -p 80:80 -p 443:443 --log-driver=syslog --restart always \
  -v /opt/ncsa-shib-idp/config/tomcat/server.xml:/usr/local/tomcat/conf/server.xml \
  -v /opt/ncsa-shib-idp/config/etc/grid-security/hostkey.pem:/etc/grid-security/hostkey.pem \
  -v /opt/ncsa-shib-idp/credentials/shib-idp:/opt/shibboleth-idp/credentials \
  -v /opt/ncsa-shib-idp/credentials/tomcat:/opt/certs \
terrencegf/ncsa-shib-idp
