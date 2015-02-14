GIT_SSH='c:\Program Files (x86)\PuTTY\plink.exe'
RAMPDIR='c:\users\alym\vc\rampsync'
THEMES='canada intranet usability'
VER=$1
TAG=v$VER

tag_sync()
{
    sed -i "s/\"version\".*/\"version\":\ \"$VER\",/" package.json
    sed -i "s/\"version\".*/\"version\":\ \"$VER\",/" bower.json
    git ci -am "qc build script update to $1"
    git tag $1
    git push origin develop
    git push origin $1
    git push github develop
    git push github $1
}

cd $RAMPDIR/ramp
git co develop
git pull
sed -i "s/\"version\".*/\"version\":\ \"$VER\",/" yuidoc.json
tag_sync $TAG

for t in $THEMES; do
    cd $RAMPDIR/ramp-theme-$t
    git co develop
    git pull
    sed -i "s/\"ramp-pcar\".*/\"ramp-pcar\":\ \"https:\/\/github.com\/RAMP-PCAR\/RAMP-PCAR.git#$TAG\",/" bower.json
    tag_sync $TAG
done
