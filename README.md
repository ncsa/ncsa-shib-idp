# Shibboleth Identity Provider (IdP) for NCSA

This repository contains the files necessary to build the Shibboleth
Identity Provider for NCSA (idp.ncsa.illinois.edu) as a Docker container. It
is based on the [Shibboleth IdP Docker Linux Container
(4.x)](https://github.internet2.edu/docker/shib-idp) as provided by the
[InCommon Trusted Access Platform
(TAP)](https://spaces.at.internet2.edu/x/fQFbC). It was built using hybrid
approach where most files are "baked-in" but secrets are mounted on the docker
host.  The secrets are stored elsewhere in a [secure GitLab server at
NCSA](https://git.security.ncsa.illinois.edu/cisr/ncsa-shib-idp).

## Servers

[idp.ncsa.illinois.edu](https://idp.ncsa.illinois.edu/idp/) is hosted on
servers managed by NCSA Security Operations. There are 3 VMs which host the
Docker servers for the NCSA IdP: `barge1`, `barge2`, and
`barge-dev`. The Docker servers are independent, i.e., not using Docker
Swarm or Kubernetes. Setting the "active" production host involves setting a
virtual Ethernet interface to "up" on one of `barge1` or `barge2`.
This is achieved with [ucarp](https://github.com/jedisct1/UCarp). The Docker
containers are configured to listen to connections for http/https (80/443)
on the host VMs, and the VM firewalls are configured to allow all traffic
for these ports. 

### Hosts and IP Addresses

| Hostname                               | IP Address     | Use |
|----------------------------------------|----------------|-----|
| barge-vip.security.ncsa.illinois.edu   | 141.142.148.27 | Virtual IP address listened to by barge1/2 and used by DNS
| barge1.security.ncsa.illinois.edu      | 141.142.148.28 | Primary production Docker server for idp.ncsa.illinois.edu |
| barge2.security.ncsa.illinois.edu      | 141.142.148.29 | Secondary production Docker server for idp.ncsa.illinois.edu |
| barge-dev.security.ncsa.illinois.edu   | 141.142.228.7  | Development Docker server for idp.ncsa.illinois.edu |

## Files

The configuration files in this repository were taken from a Shibboleth IdP
3.4.x installation. The recommended upgrade procedure for Shibboleth IdP 4.x
is to start with a good Shibboleth IdP 3.x installation and install 4.x on
top of it. However, this was not possible since the Shibboleth IdP Docker
Linux container was based on a fresh 4.x installation. So pains were taken
to modify configuration files as needed to preserve correct attribute
assertion.

This respository contains files without any secrets. Configuration files
with secrets (such as the salt for hashing) should be installed on the
Docker host in the `/opt/ncsa-shib-idp` directory. These files are stored in
a [GitLab respository at
NCSA](https://git.security.ncsa.illinois.edu/cisr/ncsa-shib-idp). Access to
this GitLab server is restricted to the NCSA Security bastion hosts (e.g.,
bastion1.security.ncsa.illinois.edu). So in order to clone the repository,
you will need to configure git SSH to proxy from barge1/2 through one of
the bastion hosts. See [GitLab Setup](gitlabsetup.md) for more information.

The files containing secrets are listed below. Note that file permissions
are important since these files will be copied into the running Docker
container.

```
/opt/ncsa-shib-idp/
├── [drwxr-xr-x root     docker  ]  config
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

## Updating

After making changes to any of the files in this repository, increment the
`VERSION` file using [semantic versioning](https://semver.org/). You may also
need to increment the `VERSION` file if the upstream InCommon TAP Shibboleth
IdP container has been updated, e.g., due to a Tomcat vulnerability. Push
the changes to GitHub and tag the update as follows:

```
git pull               # Ensure local repo is current
VERSION=`cat VERSION`  # Get current version from file

git add -A
git commit -m "Version $VERSION"
git tag -a "$VERSION" -m "Version $VERSION"
git push -u origin main
git push --tags
```

## Building

To build the container, you must have Podman/Docker installed and configured
appropriately. Then build the container as follows.

```
sh build.sh
```

This will result in a container `ncsa/shib-idp:latest`, plus several
tagged images needed when uploading the container to a package repository.

## Uploading Container to GitHub Container (Packages) Registry

We use GitHub's Container (Packages) Registry for storing the
Docker image. In order to push a Docker image to GitHub Packages, you must
use a [Personal Access Token (Classic version)](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry)
that has been configured with read/write/delete permissions on packages.

To create a [Personal Access Token (classic)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens),
log in to GitHub and visit your [Tokens (classic)](https://github.com/settings/tokens)
page. Click the "Generate new token" button and select "Generate new token (classic)"
from the dropdown menu. In the "Note" field, enter something like 
"GitHub Packages Registry Personal Token". Set the "Expiration" field to "No expiration".
Then check the checkboxes for "write:packages" and "delete:packages". Finally,
click the "Generate token" button at the bottom of the page. Record the resulting
token value since it will not be shown to you again.

Now you can upload the new version of the built container to
[GitHub](https://github.com/ncsa/ncsa-shib-idp/pkgs/container/ncsa-shib-idp).

```
sh push.sh

GitHub Username: terrencegf
GitHub Personal Token: (password not echoed) Login Succeeded!
VERSION environment variable is not set. Setting it to 2.0.4 .
Getting image source signatures
Copying blob 7fdd5c7b1dbd done   | 
Copying blob 3786e68e4ed7 done   | 
. . .
Writing manifest to image destination

```

## Working with Two Production Servers via "ucarp"

While the NCSA Shibboleth IdP Docker container is running on all barge
VMs, only one of barge1 / barge2 actually handles requests for
<https://idp.ncsa.illinois.edu>. Which barge instance is "active" is
determined by a virtual Ethernet interface for 141.142.148.27
(barge-vip.security.ncsa.illinois.edu). There is a DNS CNAME record for
idp.ncsa.illinois.edu which points to barge-vip.security.ncsa.illinois.edu .
In order to easily swap between barge1 and barge2 with this virtual
IP address, use [ucarp](https://ucarp.wordpress.com/)
([man page](http://manpages.ubuntu.com/manpages/bionic/man8/ucarp.8.html)).

There are two ways see if barge1/2 is the "active" host:

1.  `ip address | grep 141.142.148.27`
1.  `sudo pkill -10 ucarp && sudo journalctl -u ucarp@252 | grep MASTER`

In order to "swap" which server is active, ensure you are on the "active"
server (a.k.a., MASTER), and demote it to BACKUP as follows:

*   `sudo pkill -12 ucarp`
*   `sudo pkill -10 ucarp && sudo journalctl -u ucarp@252 | grep BACKUP`

The other server will notice that there is no MASTER server and grab control
of the virtual interface.

The "active" (a.k.a., MASTER) server remains the "active" server until it is
demoted to BACKUP. Note that there is no way to "promote" the BACKUP server
to MASTER. You must demote the MASTER server to BACKUP.

## Running

```
cd /opt/ncsa-shib-idp
sh run.sh
### If prompted to select a repository, choose ghcr.io
```

## Viewing the Running Container

You can view the logs for the running container.

```
sh logs.sh
```

The IdP is running when you see a line like:

```
tomcat;catalina.out;dev;nothing;2024-05-08 13:53:26,140 [main] INFO  org.apache.catalina.startup.Catalina- Server startup in [35934] milliseconds
```

You can break into the running container as follows.

```
sh inspect.sh
```

## Stopping

```
sh stop.sh
```

## Deleting Images

```
sh delete.sh
```

## Updating the Services with a new Docker Image

Once a new Docker container image has been pushed to [Docker
Hub](https://hub.docker.com/repository/docker/ncsa/shib-idp/), we need to
update the local container instances on barge-dev, barge1, and
barge2 (in that order), testing as we go. Updating the container consists
of stopping the container, removing the container, cleaning up references to
the container, and starting the container again (which will pull in the
latest tagged container version).

:warning: **WARNING!** :warning: Make sure that the current VM is NOT
"active" (a.k.a., MASTER), e.g.:

```
ip address | grep 141.142.148.27  # should be empty
```

```
# Stop the current instance
cd /opt/ncsa-shib-idp
sh stop.sh

# Remove the current Docker image
sh delete.sh

# Start the service, which will pull down the "latest" image
sh run.sh
### If prompted to select a repository, choose docker.io

# Monitor the startup sequence 
sh logs.sh

# Look for the following log message:
# INFO  org.apache.catalina.startup.Catalina- Server startup in [34387] milliseconds
```

## Testing Running Instances

Testing idp.ncsa.illinois.edu on each Docker instance is easy since all
interaction with the IdP is initiated by the client (e.g., the user's
browser). So to test a specific Docker instance, you simply need to add an
entry in your local `/etc/hosts` file which points to the server you want to
use. For example, in order to test the IdP running on barge-dev, add the
following line to your local `/etc/hosts` file:

```
141.142.228.7  idp.ncsa.illinois.edu  # Use barge-dev for NCSA IdP
```

Change the IP address to 141.142.148.28 or 141.142.148.29 to test barge1
or barge2 instead.

### Test ECP Login

You must first test ECP (command line) access in order to make Duo
authentication work for both ECP and web-based access. ECP testing is done
with the <https://cilogon.org/ecp.pl> script.

```
wget https://cilogon.org/ecp.pl
perl ecp.pl --proxyfile --idpname super --certreq create --lifetime 12
    Enter a username for the Identity Provider: <NCSA Kerberos username>
    Enter a password for the Identity Provider: <NCSA Kerberos password>
    <You will be prompted to approve an automatic Duo Push.>
grid-proxy-info
    subject  : /DC=org/DC=cilogon/C=US/O=National Center for Supercomputing Applications/CN=NCSA USER A12345
    issuer   : /DC=org/DC=cilogon/C=US/O=CILogon/CN=CILogon Basic CA 1
    identity : /DC=org/DC=cilogon/C=US/O=National Center for Supercomputing Applications/CN=NCSA USER A12345
    type     : end entity credential
    strength : 2048 bits
    path     : /tmp/x509up_u12345
    timeleft : 11:58:44
```

### Test Web Login

Next, go to <https://test.cilogon.org/testidp/> using a single
Private/Incognito window and select "National Center for Supercomputing
Applications". Log in with your NCSA Kerberos username and
password, and verify that you got all of the User Attributes you typically
get.

When you are finished testing, remove the extra line from your `/etc/hosts`
file (or prepend with `#` to comment it out).

If you are updating barge1/2 , make sure to test new Docker instances
before making them "live" with ucarp.

## SSL Certificate

The Tomcat process needs an SSL certificate for the `https://` connection.
This is stored in the `/opt/ncsa-shib-idp/credentials/tomcat/keystore.jks`
file which contains an InCommon SSL certificate for `idp.ncsa.illinois.edu`.
This certificate expires after a year. In order to update the certificate,
you will need to create a new certificate signing request (CSR), submit it
to the [InCommon Certificate
Service](https://cert-manager.com/customer/InCommon), and replace the
existing (expired) SSL certificate with the new one. 

### Generate a new Certificate Signing Request (CSR)

```
openssl req -nodes \
            -newkey rsa:2048 \
            -keyout idp_ncsa_illinois_edu.key \
            -subj "/CN=idp.ncsa.illinois.edu/emailAddress=help+idp@ncsa.illinois.edu" \
            -out idp_ncsa_illinois_edu.csr
```

### Submit the CSR to InCommon

To do this step, you should have access to the [InCommon Certificate
Service](https://cert-manager.com/customer/InCommon). If you do not have
access, you can email the resulting `idp_ncsa_illinois_edu.csr` file to
[help+idp@ncsa.illinois.edu](mailto:help+idp@ncsa.illinios.edu) and ask
someone get a certificate on your behalf. 

1. Log in to the [InCommon Certificate
   Service](https://cert-manager.com/customer/InCommon) .
1. Use the [hamburger menu](https://en.wikipedia.org/wiki/Hamburger_button)
   in the upper left corner and select [Certificates -> SSL
   Certificates](https://cert-manager.com/customer/InCommon?locale=en#ssl_certificates). 
1. In the main window, click the "+" (Add) button in the upper right corner.
1. For "Select the Enrollment Method", choose the "Using a Certificate
   Signing Request (CSR)" radio button, then click the "Next" button.
1. On the "Details" page, ensure the following are set:
   - Organization: University of Illinois
   - Department: NCSA
   - Certificate Profile: InCommon SSL (SHA-2)
   - Certifiate Term: 398 Days
   - Requester: (Your name)
   - Comments: (blank)
   - External Requestors: help+idp@ncsa.illinois.edu

   Then click the "Next" button.
1. On the "CSR" page, paste the contents of the `idp_ncsa_illinois_edu.csr` file
   (including the BEGIN and END lines) into the "CSR" text box, then click the
   "Next" button.
1. On the "Domains" page, you should see "idp.ncsa.illinois.edu" filled in
   automatically. Click the "Next" button.
1. On the "Auto-Renewal" page, do NOT check "Enable Auto-Renewal", then click
   the "OK" button.

You should eventually get response that your SSL certificate for
idp.ncsa.illinois.edu is ready to download. In the email from
support@cert-manager.com, there are several download links. Select
"Certificate only, PEM encoded" to download the certificate. The resulting
file should be named something like `idp_ncsa_illinois_edu_cert.cer`.

You also need to download the intermediate certificates. Select the
"Intermediate(s)/Root only, PEM encoded" download link, and edit the
resulting `idp_ncsa_illinois_edu_interm.cer` to remove the last certificate in
the file (the stuff between and including the last `----- BEGIN CERTIFICATE
-----` and `----- END CERTIFICATE -----` lines) since that is a root CA
certificate installed in all major web browsers.

You should now have the 3 files needed for SSL/TLS connections:
`idp_ncsa_illinois_edu_cert,cer`, `idp_ncsa_illinois_edu.key`, and
`idp_ncsa_illinois_edu_interm.cer`. Next, you need to convert these files into
a Java keystore.

```
cat idp_ncsa_illinois_edu_cert.cer idp_ncsa_illinois_edu_interm.cer > all.pem
openssl pkcs12 \
    -export \
    -inkey idp_ncsa_illinois_edu.key \
    -in all.pem -name idp.ncsa.illinois.edu \
    -out idp_ncsa_illinois_edu.p12
keytool \
    -importkeystore \
    -srckeystore idp_ncsa_illinois_edu.p12 \
    -srcstoretype pkcs12 \
    -destkeystore keystore.jks
```

When prompted for passwords, use the "certificateKeystorePassword" value
from `/opt/ncsa-shib-idp/config/tomcat/server.xml`.

Copy the resulting `keystore.jks` file to
`/opt/ncsa-shib-idp/credentials/tomcat/keystore.jks` and restart the
shib-idp service as shown
[above](#updating-the-services-with-a-new-docker-image).

Commit the new `keystore.jks` file to the NCSA Security GitLab server and
deploy on all instances of idp.ncsa.illinois.edu. Note that deploying the
updated `keystore.jks` file via Git will probably change the file
permissions and ownership. Fix this issue as follows:

```
sudo -i
cd /opt/ncsa-ship-idp/credentials/tomcat
chown root keystore.jks
chmod 640  keystore.jks

ls -la keystore.jks
    -rw-r-----. 1 root grp_202 7094 Dec  3 09:31 keystore.jks

podman stop  shib-idp
podman start shib-idp
```
