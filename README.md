# Yubikey_Simple_Scripts
Simple Windows CMD scripts to reset and setup Yubico usb token.

"Yubico_reset" cmd script is made for automatic lockout PIN and PUK by entering same wrong values and reset token after lockout.

"Yubico_prepare" cmd script automatically generate new management key, PIN and PUK, setup yubikey slots 9a and 9e and ask PFX-certificates path to load them into token.
Both scripts at start trying to find preinstalled yubico PIV tool and wait for any key at the end.
