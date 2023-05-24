docker run -d --name shib-idp -h idp.ncsa.illinois.edu \
  -p 80:80 -p 443:443 --log-driver=syslog --restart always \
  --dns 141.142.2.2 --dns 141.142.230.144 \
  -v /opt/ncsa-shib-idp/config/tomcat/server.xml:/usr/local/tomcat/conf/server.xml \
  -v /opt/ncsa-shib-idp/credentials/shib-idp:/opt/shibboleth-idp/credentials \
  -v /opt/ncsa-shib-idp/credentials/tomcat:/opt/certs \
ncsa/shib-idp:latest
