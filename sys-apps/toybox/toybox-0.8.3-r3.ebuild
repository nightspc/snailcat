# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit flag-o-matic multiprocessing savedconfig toolchain-funcs

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/landley/toybox.git"
else
	SRC_URI="https://landley.net/code/toybox/downloads/${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

# makefile is stupid
RESTRICT="test"

DESCRIPTION="Common linux commands in a multicall binary"
HOMEPAGE="https://landley.net/code/toybox/"

# The source code does not explicitly say that it's BSD, but the author has repeatedly said it
LICENSE="BSD-2"
SLOT="0"
IUSE="make-symlinks make-hardlinks pie static"
REQUIRED_USE="make-symlinks? ( !make-hardlinks )"

PATCHES=(
	"${FILESDIR}/${PN}"-0.8.3-remove-Os.patch
	"${FILESDIR}/${PN}"-0.8.3-hardlink-install.patch
	"${FILESDIR}/${PN}"-0.8.3-ls-gnu-mdate-fix.patch
)

src_prepare() {
	default
	restore_config .config
}

src_configure() {
	filter-flags -flto* -fno-common -Wl,-z,relro -Wl,-z,now
	if use pie ; then
		filter-flags -fpic -fPIC
		append-cflags -fpie
		append-cxxflags -fpie
		if use static ; then
			append-ldflags -static-pie
		fi
	elif use static ; then
		append-ldflags -static
	fi
	tc-export CC STRIP
	export HOSTCC="$(tc-getBUILD_CC)"
	if [ -f .config ]; then
		yes "" | emake -j1 oldconfig > /dev/null
		return 0
	else
		einfo "Could not locate user configfile, so we will save a default one"
		emake -j1 defconfig > /dev/null
	fi
}

src_compile() {
	unset CROSS_COMPILE
	export CPUS=$(makeopts_jobs)
	emake V=1
}

src_test() {
	emake test
}

src_install() {
	save_config .config
	if use make-symlinks; then
		PREFIX="${ED}" emake install
	elif use make-hardlinks; then
		PREFIX="${ED}" emake install_hardlink
	else
		newbin generated/unstripped/toybox toybox
	fi
}
