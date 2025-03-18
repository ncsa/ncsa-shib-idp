if [ -z "${GITHUB_USER}" ] ; then
    until [[ "${GITHUB_USER}" ]] ; do read -rp 'GitHub Username: ' GITHUB_USER ; done
fi
if [ -z "${GITHUB_TOKEN}" ] ; then
    until [[ "${GITHUB_TOKEN}" ]] ; do read -srp 'GitHub Personal Token: ' GITHUB_TOKEN ; done
fi

echo ${GITHUB_TOKEN} | sudo podman login ghcr.io -u "${GITHUB_USER}" --password-stdin

if [ -z "${VERSION}" ] ; then
    VERSION=`cat VERSION`
    echo "VERSION environment variable is not set. Setting it to ${VERSION} ."
else
    echo "VERSION is ${VERSION} ."
fi

sudo podman push ghcr.io/ncsa/ncsa-shib-idp:${VERSION}
sudo podman push ghcr.io/ncsa/ncsa-shib-idp:latest

