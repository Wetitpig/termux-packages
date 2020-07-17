TERMUX_PKG_HOMEPAGE=https://ibotpeaches.github.io/Apktool/
TERMUX_PKG_DESCRIPTION="A tool for reverse engineering of 3rd party Android Apps."
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_VERSION=2.4.1
TERMUX_PKG_SRCURL=https://github.com/iBotPeaches/Apktool/releases/download/v${TERMUX_PKG_VERSION}/apktool_${TERMUX_PKG_VERSION}.jar
TERMUX_PKG_SHA256=bdeb66211d1dc1c71f138003ce35f6d0cd19af6f8de7ffbdd5b118d02d825a52
TERMUX_PKG_DEPENDS="aapt"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_extract_package() {
	mkdir -p "$TERMUX_PKG_SRCDIR" && cd "$TERMUX_PKG_SRCDIR"
	termux_download $TERMUX_PKG_SRCURL apktool-raw.jar $TERMUX_PKG_SHA256
}

termux_step_pre_configure() {
	# Requires Android SDK, not available on device
	if $TERMUX_ON_DEVICE_BUILD; then
		termux_error_exit "Package '$TERMUX_PKG_NAME' is not safe for on-device builds."
	fi
}

termux_step_make() {
	mkdir -p $PREFIX/share/dex
	cd "$TERMUX_PKG_SRCDIR"
	$TERMUX_D8 \
		--classpath $ANDROID_HOME/platforms/android-$TERMUX_PKG_API_LEVEL/android.jar \
		--release \
		--min-api $TERMUX_PKG_API_LEVEL \
		--output $TERMUX_PKG_TMPDIR \
		apktool-raw.jar
}

termux_step_make_install() {
	cd $TERMUX_PKG_TMPDIR
	jar cf apktool.jar classes.dex
	mv apktool.jar $TERMUX_PREFIX/share/dex/apktool.jar

	cat <<- EOF > ${TERMUX_PREFIX}/bin/apktool
	#!${TERMUX_PREFIX}/bin/sh
	dalvikvm \
		-Xmx512m \
		-cp ${TERMUX_PREFIX}/share/dex/apktool.jar \
		brut.apktool.Main "\$1" --aapt ${TERMUX_PREFIX}/bin/aapt \$\(shift; echo "\$@"\)
	EOF
	chmod +x ${TERMUX_PREFIX}/bin/apktool
}
