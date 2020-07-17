TERMUX_PKG_HOMEPAGE=https://ibotpeaches.github.io/Apktool/
TERMUX_PKG_DESCRIPTION="A tool for reverse engineering of 3rd party Android Apps."
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_VERSION=2.4.1
TERMUX_PKG_SRCURL=https://github.com/iBotPeaches/Apktool/archive/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=6e19c56da880b3ff13fd5cca7c9fcab59bd604a1b8ba6de9be4e66ebc068282a
TERMUX_PKG_DEPENDS="aapt"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	# Requires Android SDK, not available on device
	if $TERMUX_ON_DEVICE_BUILD; then
		termux_error_exit "Package '$TERMUX_PKG_NAME' is not safe for on-device builds."
	fi
}

termux_step_make() {
	cd "$TERMUX_PKG_SRCDIR"
	./gradlew build shadowJar
	mv brut.apktool/apktool-cli/build/libs/apktool-cli-all.jar apktool-cli-all.jar
	zip -d apktool-cli-all.jar prebuilt/*
	mkdir -p $PREFIX/share/dex
	$TERMUX_D8 \
		--classpath $ANDROID_HOME/platforms/android-$TERMUX_PKG_API_LEVEL/android.jar \
		--release \
		--min-api $TERMUX_PKG_API_LEVEL \
		--output $TERMUX_PKG_TMPDIR \
		apktool-cli-all.jar
}

termux_step_make_install() {
	cd $TERMUX_PKG_TMPDIR
	unzip "$TERMUX_PKG_SRCDIR"/apktool-cli-all.jar \
		-x "*.class" \
		-x "*.jar" \
		-x "pom.*" \
		-x "META-INF/*"
	jar cf apktool.jar *
	mv apktool.jar $TERMUX_PREFIX/share/dex/apktool.jar

	cat <<- EOF > ${TERMUX_PREFIX}/bin/apktool
	#!${TERMUX_PREFIX}/bin/sh
	dalvikvm \
		-Xmx512m \
		-cp ${TERMUX_PREFIX}/share/dex/apktool.jar \
		brut.apktool.Main "\$1" --aapt ${TERMUX_PREFIX}/bin/aapt $(shift; echo "\$@")
	EOF
	chmod +x ${TERMUX_PREFIX}/bin/apktool
}
