#!/bin/bash
fx_root=`dirname "$(readlink -f "$0")"`

MONO_PATH=$fx_root/mono/ exec mono $fx_root/CitizenMP.Server.exe $*
