GIT_SSH='c:\Program Files (x86)\PuTTY\plink.exe'
RAMPDIR='c:\users\alym\vc\rampsync'
THEMES='canada intranet usability'
BRANCH='develop'
VER=$1
OLDPWD=`pwd`

# undo a build
# for t in $THEMES; do cd ../ramp-$t; git push github :v5.2.0-rc1; git push origin :v5.2.0-rc1; done

cd $RAMPDIR/ramp
git fetch
git co $BRANCH
git pull
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
    git push github $BRANCH
    git push github $1
}

sed -i "s/\"version\".*/\"version\":\ \"$VER\",/" yuidoc.json
tag_sync $TAG

for t in $THEMES; do
    cd $RAMPDIR/ramp-theme-$t
    git fetch
    git co $BRANCH
    git pull
    sed -i "s/\"ramp-pcar\".*/\"ramp-pcar\":\ \"https:\/\/github.com\/RAMP-PCAR\/RAMP-PCAR.git#$TAG\",/" bower.json
    tag_sync $TAG
done
