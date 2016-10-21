#!/usr/bin/env bash
set -ex
cd "$(dirname $(readlink -f $0))"
apt="sudo apt-get install -y"
mpspath="$HOME/mps-youtube"
has_cmd() {
    hash -r $1 >/dev/null 2>&1
}
if ! has_cmd lsb_release;then
    $apt lsb-release
fi
if ! has_cmd git;then
    $apt git
fi
if ! has_cmd python;then
    $apt  python
fi
if ! has_cmd python3;then 
    $apt python3
fi
if ! has_cmd mpv;then 
    $apt  mpv
fi
if ! has_cmd screen;then 
    $apt screen
fi
if ! has_cmd virtualenv;then
    $apt python-pip python-virtualenv
fi
if uname -ar | grep -q armv;then
    if ! has_cmd alsamixer;then
        $apt alsa-utils
    fi
    if ! has_cmd virtualenv;then
        sudo pip install virtualenv
    fi
fi
if [  ! -e $mpspath ];then
    git clone https://github.com/np1/mps-youtube.git $mpspath
fi
cd $mpspath
[ ! -e $mpspath/venv/bin/ ] && virtualenv --python=python3 $mpspath/venv
. $mpspath/venv/bin/activate
[ ! -f $mpspath/venv/bin/youtube-dl ] && pip install  youtube_dl
[ ! -f $mpspath/mps-youtube/venv/bin/mpsyt ] && pip install -e .
reset
mpsyt
