if [ -z $RAMPDIR ]; then
    RAMPDIR='/d/vc/rampsync'
fi
THEMES='canada intranet usability fgp-int'
BRANCH=$2
VER=$1
OLDPWD=`pwd`

# undo a build
# cd ramp
# TAG=v5.2.0-rc1
# git tag -d $TAG && git push github :$TAG && git push origin :$TAG
# for t in $THEMES; do cd ../ramp-$t; git tag -d $TAG && git push github :$TAG && git push origin :$TAG; done

if [ -z $BRANCH ]; then
    BRANCH='develop'
fi

cd $RAMPDIR/ramp
git fetch
git co $BRANCH
git pull
git reset --hard origin/$BRANCH
if [ "$VER" == 'auto' ]; then
    VER=`python $OLDPWD/incver.py package.json`
    echo "Auto versioning with $VER"
fi
if [ -z $VER ]; then
    echo 'Must supply a version number to use for tagging'
    exit 1
fi

TAG=v$VER

tag_sync()
{
    sed -i "s/\"version\".*/\"version\":\ \"$VER\",/" package.json
    sed -i "s/\"version\".*/\"version\":\ \"$VER\",/" bower.json
    git ci -am "chore(release): automated build of $1"
    git tag $1
    git push origin $BRANCH
    git push origin $1
    if [ `git remote | grep github` ]; then
        git push github $BRANCH
        git push github $1
    fi
}

sed -i "s/\"version\".*/\"version\":\ \"$VER\",/" yuidoc.json
tag_sync $TAG

for t in $THEMES; do
    cd $RAMPDIR/ramp-theme-$t
    git fetch
    git co $BRANCH
    git pull
    git reset --hard origin/$BRANCH
    sed -i "s/\"ramp-pcar\".*/\"ramp-pcar\":\ \"https:\/\/github.com\/RAMP-PCAR\/RAMP-PCAR.git#$TAG\",/" bower.json
    tag_sync $TAG
done
