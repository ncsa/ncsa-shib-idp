# Shibboleth Identity Provider (IdP) 4 for NCSA

This repository contains the files necessary to build the Shibboleth Identity
Provider for NCSA (idp.ncsa.illinois.edu) as a Docker container. It is based on the
[Shibboleth IdP Docker Linux Container
(4.x)](https://github.internet2.edu/docker/shib-idp) as provided by the [InCommon
Trusted Access Platform (TAP)](https://spaces.at.internet2.edu/x/fQFbC). It was
built using hybrid approach with most files "baked-in" and secrets mounted on the
docker host. The secrets are stored elsewhere in a [secure GitLab server at
NCSA](https://git.security.ncsa.illinois.edu/cisr/ncsa-shib-idp).

## Files

The configuration files in this repository were taken from a Shibboleth IdP 3.4.x
installation. The recommended upgrade procedure for Shibboleth IdP 4.x is to start
with a good Shibboleth IdP 3.x installation and install 4.x on top of it. However,
this was not possible since the Shibboleth IdP Docker Linux container was based on a
fresh 4.x installation. So pains were taken to modify configuration files as needed
to preserve correct attribute assertion.

This respository contains files without any secrets. Configuration files with
secrets (such as the salt for hashing) should be installed on the Docker host in the
`/opt/ncsa-shib-idp` directory. These files are stored in a [GitLab respository at
NCSA](https://git.security.ncsa.illinois.edu/cisr/ncsa-shib-idp). The file listing
is shown below. Note that file permissions are important since these files will be
copied into the running Docker container.

```
/opt/ncsa-shib-idp/
├── [drwxr-xr-x root     docker  ]  config
│   ├── [drwxr-xr-x root     docker  ]  etc
│   │   └── [drwxr-xr-x root     docker  ]  grid-security
│   │       └── [-r-------- root     docker  ]  hostkey.pem
│   └── [drwxr-xr-x root     docker  ]  tomcat
│       └── [-rw-r----- root     docker  ]  server.xml
├── [drwxr-xr-x root     docker  ]  credentials
│   ├── [drwxr-xr-x root     docker  ]  shib-idp
│   │   ├── [-rw-r----- root     docker  ]  ca-bundle.crt
│   │   ├── [-rw-r----- root     docker  ]  HTTP-idp.ncsa.illinois.edu.keytab
│   │   ├── [-rw-r----- root     docker  ]  idp-backchannel.crt
│   │   ├── [-rw-r----- root     docker  ]  idp-backchannel.p12
│   │   ├── [-rw-r----- root     docker  ]  idp-encryption.crt
│   │   ├── [-rw-r----- root     docker  ]  idp-encryption.key
│   │   ├── [-rw-r----- root     docker  ]  idp-signing.crt
│   │   ├── [-rw-r----- root     docker  ]  idp-signing.key
│   │   ├── [-rw-r----- root     docker  ]  inc-md-cert-mdq.pem
│   │   ├── [-rw-r----- root     docker  ]  sealer.jks
│   │   ├── [-rw-r----- root     docker  ]  sealer.kver
│   │   └── [-rw-r----- root     docker  ]  secrets.properties
│   └── [drwxr-xr-x root     docker  ]  tomcat
│       └── [-rw-r----- root     docker  ]  keystore.jks
└── [-rw-r--r-- root     docker  ]  run.sh
```

## Building

To build the container, you must have Docker installed and configured appropriately.
Then build the container as follows.

```
sh build.sh
```

This will result in a container `terrencegf/ncsa-shib-idp:latest`. 

## Uploading Container to Docker Hub

After making changes to any of the files in this repository, increment the VERSION
file (using [semantic versioning](https://semver.org/)), push changes to GitHub, and
tag the update. Then you can upload a new version of the built container to [Docker
Hub](https://hub.docker.com) (or some other container repository). 

```
git pull               # Ensure local repo is current
VERSION=`cat VERSION`  # Get current version from file
sh build.sh            # Rebuild the container

git add -A
git commit -m "version $VERSION"
git tag -a "$VERSION" -m "version $VERSION"
git push
git push --tags

docker tag  terrencegf/ncsa-shib-idp:latest terrencegf/ncsa-shib-idp:$VERSION
docker push terrencegf/ncsa-shib-idp:latest
docker push terrencegf/ncsa-shib-idp:$VERSION
```

## Running

```
sh run.sh
docker ps
```

## Viewing Running Container

You can log into the running container using the `inspect.sh` script, which does the
following.

```
docker exec -t -i idp-ncsa /bin/bash
```

## Stopping

```
docker stop idp-ncsa
docker rm idp-ncsa
```

## SSL Certificate

The Tomcat process needs an SSL certificate for the `https://` connection. This is
stored in the `/opt/ncsa-shib-idp/credentials/tomcat/keystore.jks` file which
contains an InCommon SSL certificate for `idp.ncsa.illinois.edu`. This certificate
expires after a year. In order to update the certificate, you will need to create a
new certificate signing request (CSR), submit it to the [InCommon Certificate
Service](https://cert-manager.com/customer/InCommon), and replace the existing
(expired) SSL certificate with the new one. 

### Generate a new CSR using the existing Java keystore.

```
keytool -certreq \
        -keyalg RSA \
        -keystore /opt/ncsa-shib-idp/credentials/tomcat/keystore.jks \
        -alias idp.ncsa.illinois.edu \
        -file idp_ncsa_illinois_edu.csr
Enter keystore password: <password not echoed>
```

The keystore password can be found in `/opt/ncsa-shib-idp/config/tomcat/server.xml`
as the "keystorePass" value.

### Submit the CSR to InCommon

To do this step, you should have access to the [InCommon Certificate
Service](https://cert-manager.com/customer/InCommon). If you do not have access, you
can email the resulting `idp_ncsa_illinois_edu.csr` file to
[help+idp@ncsa.illinois.edu](mailto:help+idp@ncsa.illinios.edu) and ask someone get
a certificate on your behalf. 

1. Log in to the [InCommon Certificate Service](https://cert-manager.com/customer/InCommon) .
2. Click on the "Certificates" tab, then click the "+ Add" button.
3. Select the "Manual creation of CSR" radio button, then click the "Next >" button.
4. On the "CSR" page, paste the contents of the `idp_ncsa_illinois_edu.csr` file
   into the "CSR" text box, then click the "Next >" button.
5. On the "Basic Info" page, fill in the fields as follows, then click the "Next >"
   button.
  - Organization: University of Illinois
  - Department: NCSA
  - Certificate Profile: InCommon SSL (SHA-2)
  - Certifiate Term: 398 Days
  - Common Name: idp.ncsa.illinois.edu (should be filled in automatically)
  - Requester: (Your name)
  - External Requestor: help+idp@ncsa.illinois.edu
6. On the "Auto renew" page, optionally check the checkbox for "Enable auto renewal
   of this certificate", then click the "OK" button.

After a few minutes, you should receive an email that your certificate is ready. In
that email, there are several download links under the "Available formats" heading.
Select the last one listed "as PKCS#7". This will download a file named
`idp_ncsa_illinois_edu.p7b`. 

### Update the SSL Certificate in the Existing keystore.jks

Next, import the new `idp_ncsa_illinois_edu.p7b` certificate into the existing
`keystore.jks`, replacing the old certificate.

```
keytool -import \
        -trustcacerts \
        -alias idp.ncsa.illinois.edu \
        -file idp_ncsa_illinois_edu.p7b \
        -keystore /opt/ncsa-shib-idp/credentials/tomcat/keystore.jks
Enter keystore password: <password not echoed>
```

