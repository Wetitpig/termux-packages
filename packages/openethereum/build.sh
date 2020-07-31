TERMUX_PKG_HOMEPAGE=https://openethereum.github.io
TERMUX_PKG_DESCRIPTION="An ethereum client written in rust"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_VERSION=3.0.1
TERMUX_PKG_SRCURL=https://github.com/openethereum/openethereum/archive/v${TERMUX_PKG_VERSION}.zip
TERMUX_PKG_SHA256=79c69580339097c67e3d36131aff037de6959095d555c9789b1cf52fa7187d93
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--no-default-features --features final"

termux_step_pre_configure() {
	termux_setup_cmake

	termux_setup_rust
	cargo clean
}
