#!/bin/bash

if lsmod | grep -q uvcvideo; then
    sudo /sbin/modprobe -r uvcvideo &>/dev/null
else
    sudo /sbin/modprobe uvcvideo &>/dev/null
fi

