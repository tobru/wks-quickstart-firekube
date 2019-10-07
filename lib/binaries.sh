footloose_help() {
    echo "firekube requires footloose to spawn VMs that will be used as Kubernetes nodes."
    echo ""
    echo "Please install footloose version $FOOTLOOSE_VERSION or later:"
    echo ""
    echo "  • GitHub project  : https://github.com/weaveworks/footloose"
    echo "  • Latest release  : https://github.com/weaveworks/footloose/releases"
    echo "  • Installation    : https://github.com/weaveworks/footloose#install"
    echo "  • Required version: $FOOTLOOSE_VERSION"
}

footloose_download() {
    local cmd=$1
    local version=$2

    os=$(goos)
    case $os in
    linux)
        do_curl_binary $cmd https://github.com/weaveworks/footloose/releases/download/${version}/footloose-${version}-${os}-$(arch)
        ;;
    darwin)
        do_curl_tarball $cmd https://github.com/weaveworks/footloose/releases/download/${version}/footloose-${version}-${os}-$(arch).tar.gz
        ;;
    *)
        error "unknown OS: $os"
        ;;
    esac
}

footloose_version() {
    local cmd="footloose"
    local req=$1
    local version

    if ! version=$($cmd version | sed -n -e 's#^version: \([0-9g][0-9\.it]*\)$#\1#p') || [ -z "$version" ]; then
        help $cmd "error running '$cmd version'."
    fi

    if [ "$version" == "git" ]; then
        log "$cmd: detected git build, continuing"
        return
    fi

    version_check $cmd $version $req
}

ignite_help() {
    echo "firekube with the ignite backend requires ignite to spawn VMs that will be used as Kubernetes nodes."
    echo ""
    echo "Please install ignite version $IGNITE_VERSION or later:"
    echo ""
    echo "  • GitHub project  : https://github.com/weaveworks/ignite"
    echo "  • Latest release  : https://github.com/weaveworks/ignite/releases"
    echo "  • Installation    : https://github.com/weaveworks/ignite#installing"
    echo "  • Required version: $IGNITE_VERSION"
}

ignite_download() {
    local cmd=$1
    local version=$2

    do_curl_binary $cmd https://github.com/weaveworks/ignite/releases/download/v${version}/ignite-$(goarch)
}

ignite_version() {
    local cmd="ignite"
    local req=$1
    local version

    if ! version=$($cmd version -o short | sed -n -e 's#^v\(.*\)#\1#p') || [ -z "$version" ]; then
        help $cmd "error running '$cmd version'."
    fi

    version_check $cmd $version $req
}

jk_help() {
    echo "firekube needs jk to generate configuration manifests."
    echo ""
    echo "Please install jk version $JK_VERSION or later:"
    echo ""
    echo "  • GitHub project  : https://github.com/jkcfg/jk"
    echo "  • Latest release  : https://github.com/jkcfg/jk/releases"
    echo "  • Installation    : https://github.com/jkcfg/jk#quick-start"
    echo "  •                 : https://jkcfg.github.io/#/documentation/quick-start"
    echo "  • Required version: $JK_VERSION"
}

jk_download() {
    local cmd=$1
    local version=$2

     do_curl_binary $cmd https://github.com/jkcfg/jk/releases/download/${version}/jk-$(goos)-$(goarch)
}

jk_version() {
    local cmd="jk"
    local req=$1
    local version

    if ! version=$($cmd version | sed -n -e 's#^version: \(.*\)#\1#p') || [ -z "$version" ]; then
        help jk "error running '$cmd version'."
    fi

    version_check $cmd $version $req
}

wksctl_help() {
    echo "firekube needs wksctl to install Kubernetes."
    echo ""
    echo "Please install wksctl version $WKSCTL_VERSION or later:"
    echo ""
    echo "  • GitHub project  : https://github.com/weaveworks/wksctl"
    echo "  • Latest release  : https://github.com/weaveworks/wksctl/releases"
    echo "  • Installation    : https://github.com/weaveworks/wksctl/#install-wksctl"
    echo "  • Required version: $WKSCTL_VERSION"
}

wksctl_download() {
    local cmd=$1
    local version=$2

    do_curl_tarball $cmd https://github.com/weaveworks/wksctl/releases/download/${version}/wksctl-${version}-$(goos)-$(arch).tar.gz
}

wksctl_version() {
    local cmd="wksctl"
    local req=$1
    local version

    if ! version=$($cmd version | sed -n -e 's#^\(.*\)#\1#p') || [ -z "$version" ]; then
        help $cmd "error running '$cmd version'."
    fi

    if [ "$version" == "undefined" ]; then
        log "$cmd: detected git build, continuing"
        return
    fi

    version_check $cmd $version $req
}

