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
GURL=https://github.com/kiorky/mps-youtube.git
OGURL=https://github.com/mps-youtube/mps-youtube.git
OBRANCH=develop
BRANCH=$OBRANCH
if [  ! -e $mpspath ];then
    git clone $GURL $mpspath
fi
cd $mpspath || exit 1
git config user.email "Vous@exemple.com"
git config user.name "Votre Nom"
git k || true
git remote rm origin || true
git remote rm g || true
git remote add origin $GURL
git remote add g $OGURL
git fetch --all
git stash
git reset --hard origin/$BRANCH
git pull --rebase g $OBRANCH
cd $mpspath
[ ! -e $mpspath/venv/bin/ ] && virtualenv --python=python3 $mpspath/venv
. $mpspath/venv/bin/activate
if [ ! -f $mpspath/venv/bin/youtube-dl ];then
    if [ ! -e $mpspath/youtube-dl ];then
        git clone https://github.com/rg3/youtube-dl.git
    fi
    cd youtube-dl;git stash;git pull;pip install -e .;cd ..
fi
[ ! -f $mpspath/mps-youtube/venv/bin/mpsyt ] && pip install -e .
reset
export YT_API_KEY=$(grep '"API' ~/.config/mps-youtube/config.json |awk '{print $2}'|sed "s/.//"|sed -re "s/\".*$//")
if [[ -n $YT_API_KEY ]];then
    sed -i -r \
        -e "s/api_key = \"[^\"]*\"/api_key = \"$YT_API_KEY\"/g" \
        -e "s/api_key\", \"[^\"]\"/api_key\", \"$YT_API_KEY\"/g" \
        $(find -name g.py -or -name config.py|egrep "config|pafy")
fi
rm -rvf ~/.config/mps-youtube/cache_py*
youtube-dl --rm-cache-dir
find $mpspath -name "**pycache**"|xargs rm -rf
mpsyt --debug --logging
