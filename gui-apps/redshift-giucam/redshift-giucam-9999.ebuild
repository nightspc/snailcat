# Copyright 2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{4,5,6} )

inherit systemd autotools eutils gnome2-utils git-r3 python-r1

DESCRIPTION="A screen color temperature adjusting software"
HOMEPAGE="http://jonls.dk/redshift/"
EGIT_REPO_URI="https://github.com/giucam/redshift"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="ayatana geoclue gtk nls wayland"

COMMON_DEPEND="
	>=x11-libs/libX11-1.4
	x11-libs/libXxf86vm
	x11-libs/libxcb
	x11-libs/libdrm
	ayatana? ( dev-libs/libappindicator:3[introspection] )
	geoclue? ( app-misc/geoclue:2.0 dev-libs/glib:2 )
	gtk? ( ${PYTHON_DEPS} )
	wayland? (
		dev-libs/wayland
		gui-libs/wlroots
	)"
RDEPEND="
	${COMMON_DEPEND}
	gtk? (
		dev-python/pygobject[${PYTHON_USEDEP}]
		x11-libs/gtk+:3[introspection]
		dev-python/pyxdg[${PYTHON_USEDEP}]
	)"
DEPEND="
	${COMMON_DEPEND}
	>=dev-util/intltool-0.50
	nls? ( sys-devel/gettext )
"
REQUIRED_USE="gtk? ( ${PYTHON_REQUIRED_USE} )"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	use gtk && python_setup

	econf \
		--disable-silent-rules \
		$(use_enable nls) \
		--enable-drm \
		--enable-randr \
		--enable-vidmode \
		--disable-wingdi \
		\
		--disable-corelocation \
		$(use_enable geoclue geoclue2) \
		\
		$(use_enable gtk gui) \
		--with-systemduserunitdir="$(systemd_get_userunitdir)" \
		--disable-quartz \
		--disable-ubuntu \
		$(use_enable wayland)
}

_impl_specific_src_install() {
	emake DESTDIR="${D}" pythondir="$(python_get_sitedir)" \
			-C src/redshift-gtk install
}

src_install() {
	emake DESTDIR="${D}" UPDATE_ICON_CACHE=/bin/true install

	if use gtk; then
		python_foreach_impl _impl_specific_src_install
		python_replicate_script "${D}"/usr/bin/redshift-gtk
		dosym redshift-gtk /usr/bin/gtk-redshift
	fi
}

pkg_preinst() {
	use gtk && gnome2_icon_savelist
}

pkg_postinst() {
	use gtk && gnome2_icon_cache_update
}

pkg_postrm() {
	use gtk && gnome2_icon_cache_update
}
