#!/usr/bin/env bash

# Dependency Tree
#
# tmux
# |
# |`- pkgconf (replaces pkg-config)
# |   |
# |   |`- libtool
# |   |
# |    `- automake
# |       |
# |       |`- autoconf
# |           |
# |            `- m4
# |
# |`- ncurses
# |   |
# |    `- autoconf
# |       |
# |        `- m4
# |
#  `- libevent

TARGET_TOOLS=$@

PREFIX="${HOME}/local/sample"
PATH="${PREFIX}/bin:${PATH}"
CPATH="${PREFIX}/include"
LIBRARY_PATH="${PREFIX}/lib"
LD_LIBRARY_PATH="${PREFIX}/lib"
PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"

DL_DIR="${HOME}/local/tmux-downloads"

M4_VERSION="1.4.19"
AUTOCONF_VERSION="2.72"
AUTOMAKE_VERSION="1.16.5"
LIBTOOL_VERSION="2.4.7"
NCURSES_VERSION="6.5"
LIBEVENT_VERSION="2.1.12"
PKGCONF_VERSION="pkgconf-2.2.0"
UTF8PROC_VERSION="2.9.0"
TMUX_VERSION="3.4"

PKGCONF_URL='https://github.com/${TOOL}/${TOOL}/archive/refs/tags/${TOOL_VERSION}.tar.gz'
LIBEVENT_URL='https://github.com/${TOOL}/${TOOL}/archives/refs/tags/${VERSION}.tar.gz'
UTF8PROC_URL='https://github.com/JuliaStrings/${TOOL}/releases/download/v${VERSION}/${TOOL_VERSION}.tar.gz'
TMUX_URL='https://github.com/${TOOL}/${TOOL}/releases/download/${VERSION}/${TOOL_VERSION}.tar.gz'

FLAGS=" --prefix=${PREFIX}"
LIBEVENT_FLAGS=(" --prefix=${PREFIX}" " --disable-openssl" " --enable-shared")
NCURSES_FLAGS=(" --prefix=${PREFIX}" " --with-shared" " --with-termlib" " --enable-pc-files" " --with-pkg-config-libdir=${PREFIX}/lib/pkgconfig")
UTF8PROC_FLAGS=(" prefix=${PREFIX}")
TMUX_FLAGS=(" --prefix=${PREFIX}" " --enable-utf8proc")

MANPATH="${PREFIX}/share/man:${MANPATH}"

check_download_dir () {
    echo "Checking for download directory..."
    [ -d ${DL_DIR} ] || (mkdir -p ${DL_DIR} && echo "Creating download directory: ${DL_DIR}")
}

check_prefix_dir () {
    echo "Checking for install directory..."
    [ -d ${PREFIX} ] || (mkdir -p ${PREFIX} && echo "Creating install directory: ${PREFIX}")
}

gnu_tool_install () {
    TOOL="${1}"
    VERSION="${2}"
    TOOL_VERSION="${TOOL}-${VERSION}"
    shift 2
    INSTALL_FLAGS="${@}"

    echo "Executing ${TOOL_VERSION} install checks..."

    echo "Checking for ${TOOL_VERSION}.tar.gz..."
    [ -f ${DL_DIR}/${TOOL_VERSION}.tar.gz ] \
        || curl -L https://ftp.gnu.org/gnu/${TOOL}/${TOOL_VERSION}.tar.gz -o ${DL_DIR}/${TOOL_VERSION}.tar.gz
    

    echo "Extracting ${TOOL_VERSION}.tar.gz..."
    tar xzf ${DL_DIR}/${TOOL_VERSION}.tar.gz -C ${DL_DIR} || echo "ERROR: ${TOOL_VERSION} extract failed!"

    echo "Executing: ./configure --prefix=${PREFIX} ${INSTALL_FLAGS} && make && make install..."
    cd ${DL_DIR}/${TOOL_VERSION} \
    && sh configure --prefix=${PREFIX} ${INSTALL_FLAGS} && make && make install \
    && echo "${TOOL_VERSION} successfully installed!"  && cd - \
    || echo "ERROR: ${TOOL_VERSION} failed to install!" && cd -
}

github_tool_install () {
    TOOL="${1}"
    VERSION="${2}"
    URL="${3}"
    TOOL_VERSION="${TOOL}-${VERSION}"
    shift 3
    INSTALL_FLAGS="${@}"

    echo "Executing ${TOOL_VERSION} install checks..."

    echo "Checking for ${TOOL_VERSION}.tar.gz..."
    [ -f ${DL_DIR}/${TOOL_VERSION}.tar.gz ] \
        || curl -L https://github.com/${TOOL}/${TOOL}/archive/refs/tags/${TOOL_VERSION}.tar.gz -o ${DL_DIR}/${TOOL_VERSION}.tar.gz

    echo "Extracting ${TOOL_VERSION}.tar.gz..."
    tar xzf ${DL_DIR}/${TOOL_VERSION}.tar.gz -C ${DL_DIR} || echo "ERROR: ${TOOL_VERSION} extract failed!"

    echo "Executing: ./autogen.sh"
    cd ${DL_DIR}/${TOOL_VERSION} \
        && [ -f autogen.sh ] && sh autogen.sh \
        || echo "ERROR: No autogen.sh found!" 

    echo "Install flags: ${INSTALL_FLAGS}"
    echo "Executing: ./configure ${INSTALL_FLAGS} && make && make install..."
    cd ${DL_DIR}/${TOOL_VERSION} && sh configure ${INSTALL_FLAGS} && make && make install \
        && echo "${TOOL_VERSION} successfully installed!"  \
        || echo "ERROR: ${TOOL_VERSION} failed to install!"
}

pkgconf_install () {
    TOOL="${1}"
    VERSION="${2}"
    TOOL_VERSION="${TOOL}-${VERSION}"
    shift 2
    INSTALL_FLAGS="${@}"

    echo "Executing ${TOOL_VERSION} install checks..."

    echo "Checking for ${TOOL_VERSION}.tar.gz..."
    # https://github.com/pkgconf/pkgconf/archive/refs/tags/pkgconf-2.2.0.tar.gz
    [ -f ${DL_DIR}/${TOOL_VERSION}.tar.gz ] \
        || curl -L https://github.com/${TOOL}/${TOOL}/archive/refs/tags/${TOOL_VERSION}.tar.gz -o ${DL_DIR}/${TOOL_VERSION}.tar.gz

    echo "Extracting ${TOOL_VERSION}.tar.gz..."
    tar xzf ${DL_DIR}/${TOOL_VERSION}.tar.gz -C ${DL_DIR} || echo "ERROR: ${TOOL_VERSION} extract failed!"

    echo "Executing: ./autogen.sh"
    cd ${DL_DIR}/${TOOL_VERSION} \
        && [ -f autogen.sh ] && sh autogen.sh \
        || echo "ERROR: No autogen.sh found!" 

    echo "Install flags: ${INSTALL_FLAGS}"
    echo "Executing: ./configure ${INSTALL_FLAGS} && make && make install..."
    cd ${DL_DIR}/${TOOL_VERSION} && sh configure --prefix=${PREFIX} ${INSTALL_FLAGS} && make && make install \
        && echo "${TOOL_VERSION} successfully installed!"  \
        || echo "ERROR: ${TOOL_VERSION} failed to install!"
}

libevent_install () {
    TOOL="${1}"
    VERSION="${2}"
    TOOL_VERSION="${TOOL}-${VERSION}"
    shift 2
    INSTALL_FLAGS="${@}"

    echo "Executing ${TOOL_VERSION} install checks..."

    echo "Checking for ${TOOL_VERSION}.tar.gz..."
    [ -f ${DL_DIR}/${TOOL_VERSION}.tar.gz ] \
        || curl -L https://github.com/${TOOL}/${TOOL}/releases/download/release-${VERSION}-stable/${TOOL_VERSION}-stable.tar.gz -o ${DL_DIR}/${TOOL_VERSION}.tar.gz
        #          https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
        #          https://github.com/libevent/libevent/archive/refs/tags/release-2.1.12-stable.tar.gz

    echo "Extracting ${TOOL_VERSION}.tar.gz..."
    tar xzf ${DL_DIR}/${TOOL_VERSION}.tar.gz -C ${DL_DIR} || echo "ERROR: ${TOOL_VERSION} extract failed!"

    echo "Executing: ./autogen.sh"
    cd ${DL_DIR}/${TOOL_VERSION}-stable \
        && [ -f autogen.sh ] && sh autogen.sh \
        || echo "ERROR: No autogen.sh found!" 

    echo "Install flags: ${INSTALL_FLAGS}"
    echo "Executing: ./configure ${INSTALL_FLAGS} && make && make install..."
    cd ${DL_DIR}/${TOOL_VERSION}-stable && sh configure --prefix=${PREFIX} ${INSTALL_FLAGS} && make && make install \
        && echo "${TOOL_VERSION} successfully installed!"  \
        || echo "ERROR: ${TOOL_VERSION} failed to install!"
}

tmux_install () {
    TOOL="${1}"
    VERSION="${2}"
    TOOL_VERSION="${TOOL}-${VERSION}"
    shift 2
    INSTALL_FLAGS="${@}"

    echo "Executing ${TOOL_VERSION} install checks..."

    echo "Checking for ${TOOL_VERSION}.tar.gz..."
    [ -f ${DL_DIR}/${TOOL_VERSION}.tar.gz ] \
        || curl -L https://github.com/${TOOL}/${TOOL}/releases/download/${VERSION}/${TOOL_VERSION}.tar.gz -o ${DL_DIR}/${TOOL_VERSION}.tar.gz
            #          https://github.com/tmux/tmux/releases/download/3.4/tmux-3.4.tar.gz

    echo "Extracting ${TOOL_VERSION}.tar.gz..."
    tar xzf ${DL_DIR}/${TOOL_VERSION}.tar.gz -C ${DL_DIR} || echo "ERROR: ${TOOL_VERSION} extract failed!"

    echo "Install flags: ${INSTALL_FLAGS}"
    echo "Executing: ./configure --prefix=${PREFIX} ${INSTALL_FLAGS} && make && make install..."
    cd ${DL_DIR}/${TOOL_VERSION}&& sh configure --prefix=${PREFIX} ${INSTALL_FLAGS} && make && make install \
        && echo "${TOOL_VERSION} successfully installed!"  \
        || echo "ERROR: ${TOOL_VERSION} failed to install!"
}

utf8proc_install ()  {
    TOOL="${1}"
    VERSION="${2}"
    TOOL_VERSION="${TOOL}-${VERSION}"
    shift 2
    INSTALL_FLAGS="${@}"

    echo "Executing ${TOOL_VERSION} install checks..."

    echo "Checking for ${TOOL_VERSION}.tar.gz..."
    [ -f ${DL_DIR}/${TOOL_VERSION}.tar.gz ] \
        || curl -L https://github.com/JuliaStrings/${TOOL}/releases/download/v${VERSION}/${TOOL_VERSION}.tar.gz -o ${DL_DIR}/${TOOL_VERSION}.tar.gz
    # https://github.com/JuliaStrings/utf8proc/releases/download/v2.9.0/utf8proc-2.9.0.tar.gz

    echo "Extracting ${TOOL_VERSION}.tar.gz..."
    tar xzf ${DL_DIR}/${TOOL_VERSION}.tar.gz -C ${DL_DIR} || echo "ERROR: ${TOOL_VERSION} extract failed!"

    echo "Executing make prefix=${PREFIX} && make install..."
    cd ${DL_DIR}/${TOOL_VERSION} \
        && make prefix=${PREFIX} ${INSTALL_FLAGS} && make ${INSTALL_FLAGS} install \
        && echo "${TOOL_VERSION} installed successfully!" \
        || echo "ERROR: ${TOOL_VERSION} failed to install!"
}

installer () {
    for TOOL in ${TARGET_TOOLS}; do
        case ${TOOL} in
            "m4" )
                gnu_tool_install ${TOOL} ${M4_VERSION}
                ;;
            "autoconf" )
                gnu_tool_install ${TOOL} ${AUTOCONF_VERSION}
                ;;
            "automake" )
                gnu_tool_install ${TOOL} ${AUTOMAKE_VERSION}
                ;;
            "libtool" )
                gnu_tool_install ${TOOL} ${LIBTOOL_VERSION} && libtool --finish ${PREFIX}/lib \
                    || echo "ERROR: libtool did not finish installation completely!"
                ;;
            "ncurses" )
                gnu_tool_install ${TOOL} ${NCURSES_VERSION} ${NCURSES_FLAGS[@]}
                ;;
            "pkgconf" )
                pkgconf_install ${TOOL} ${PKGCONF_VERSION}
                ;;
            "libevent" )
                libevent_install ${TOOL} ${LIBEVENT_VERSION} ${LIBEVENT_FLAGS[@]}
                ;;
            "utf8proc" )
                utf8proc_install ${TOOL} ${UTF8PROC_VERSION} ${UTF8PROC_FLAGS}
                ;;
            "tmux" )
                tmux_install ${TOOL} ${TMUX_VERSION} ${TMUX_FLAGS[@]}
                ;;
            "*" )
                echo "Unknown tool: ${TOOL}"
                echo "Exiting!"
                exit 1
            esac

    done
}
check_prefix_dir
check_download_dir
installer

