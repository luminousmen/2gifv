#!/bin/sh

# Copyright (c) 2017, Kirill Bobrov
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#  * Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.


GIFV_FILENAME="out.webm"

usage() {
    echo "usage: ./2gifv.sh [--in ] [--out] [--check] [-h]"
    echo "  -h, --help                   Show this help, exit"
    echo "      --check                  Check if all dependencies are installed, exit"
    echo "      --in=<file name>    Set file name for input .gif or .mkv"
    echo "      --out=<file name>   Set file name for output .gifv (the out file should be in .webm format)"
    echo ""
}

error_exit() {
	echo "$1" 1>&2
	exit 1
}


dependency_check() {
    (which ffmpeg > /dev/null 2>&1 && echo "OK: found ffmpeg") || echo "ERROR: ffmpeg not found"
    exit 2
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --in)
            IN_FILENAME=$VALUE
            echo "Input file - $IN_FILENAME"
            ;;
        --out)
            GIFV_FILENAME=$VALUE
            echo "Output file - $GIFV_FILENAME"
            ;;
        --check)
            CHECK=true
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
        shift
done


# dependency check
if [ "$CHECK" = true ] ; then
    dependency_check
fi
# /dependency check


if [ -n "$IN_FILENAME" ]; then
  EXT="${IN_FILENAME##*.}"
fi


if [ -z "$IN_FILENAME" ] ; then
    echo "ERROR: no input file provided."
fi


if [ -n "$IN_FILENAME" ] && [ "$EXT" = "gif" ] ; then
    echo "Start converting ..."
    ffmpeg -i $IN_FILENAME -c:v libvpx -crf 4 -threads 0 -an -b:v 10M -nostats -loglevel 0 $GIFV_FILENAME
    echo "Done!"
fi

if [ -n "$IN_FILENAME" ] && [ "$EXT" = "mkv" ] ; then
    echo "Start converting ..."
    ffmpeg -i $IN_FILENAME -c:v libvpx -crf 4 -threads 0 -an -ss 00:00:22 -t 00:00:5 -b:v 10M -nostats -loglevel 0 $GIFV_FILENAME
    echo "Done!"
fi
