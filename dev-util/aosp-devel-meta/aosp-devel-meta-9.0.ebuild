# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Meta package providing AOSP build environment"
HOMEPAGE="https://source.android.com/source/initializing"

LICENSE="metapackage"
SLOT="9.0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	app-crypt/gnupg
	app-arch/zip[-natspec]
	app-arch/unzip
	dev-java/icedtea:8
	dev-libs/libxslt
	dev-libs/libxml2
	dev-util/android-tools
	dev-util/ccache
	dev-util/gperf
	dev-vcs/git
	media-libs/libsdl
	media-libs/mesa
	net-misc/curl
	net-misc/rsync
	sys-devel/bc
	sys-devel/bison
	sys-devel/flex
	sys-devel/gcc[cxx]
	sys-libs/ncurses:5[abi_x86_32,tinfo]
	sys-libs/readline[abi_x86_32]
	sys-libs/zlib[abi_x86_32]
	sys-process/schedtool
	sys-fs/squashfs-tools
	x11-base/xorg-proto
	x11-libs/libX11
	x11-libs/wxGTK:3.0
"
