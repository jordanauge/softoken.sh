# softoken.sh
Automatize token generation with Softoken-II (KDE flavour)

by Jordan Augé <jordan.auge@free.fr>

License: GPLv3

Prerequisite:
 - A working version of Softoken-II installed through Wine and initialized
 - Dependencies: wine xvfb kwin qdbus xdotool kwalletmanager xsel
 - Most of them should be already present in KDE

Functionalities:
 - Stores password in kwallet
 - Uses a virtual X server in framebuffer to avoid interaction / interruption
 due to current Desktop activity (useful for scripts)
 - Copies generated token to stdout and clipboard

See also:
 - https://hub.docker.com/r/softoken/softoken-docker/~/dockerfile/
