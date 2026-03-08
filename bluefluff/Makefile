IMAGE_NAME=bluefluff
DEPS=Dockerfile
KEEPFILE=.imagebuild_$(IMAGE_NAME)
RFLAGS?=-it --network host --device /dev/bus/usb --device /dev/hci0 --cap-add NET_ADMIN --cap-add NET_RAW -v /var/run/dbus:/var/run/dbus
include ../Makefile.parent
