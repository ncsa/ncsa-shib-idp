if [ -z "${VERSION}" ] ; then
    VERSION=`cat VERSION`
    echo "VERSION environment variable is not set. Setting it to ${VERSION} ."
else
    echo "VERSION is ${VERSION} ."
fi

sudo podman image rm ghcr.io/ncsa/ncsa-shib-idp:${VERSION}
sudo podman image rm ghcr.io/ncsa/ncsa-shib-idp:latest
sudo podman image rm ncsa/shib-idp:${VERSION}
sudo podman image rm ncsa/shib-idp:latest
sudo podman image rm docker.io/i2incommon/shib-idp:latest5
