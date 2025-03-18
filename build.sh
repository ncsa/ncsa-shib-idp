if [ -z "${VERSION}" ] ; then
    VERSION=`cat VERSION`
    echo "VERSION environment variable is not set. Setting it to ${VERSION} ."
else
    echo "VERSION is ${VERSION} ."
fi

sudo podman build --no-cache --format docker -t ncsa/shib-idp:${VERSION} .
sudo podman tag shib-idp:${VERSION} ncsa/shib-idp:latest
sudo podman tag shib-idp:${VERSION} ghcr.io/ncsa/ncsa-shib-idp:${VERSION}
sudo podman tag shib-idp:latest ghcr.io/ncsa/ncsa-shib-idp:latest
