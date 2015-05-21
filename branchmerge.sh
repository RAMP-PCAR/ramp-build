if [ -z $RAMPDIR ]; then
    RAMPDIR='/d/vc/rampsync'
fi
THEMES='canada intranet usability fgp-int'
SRC=$1
DST=$2
STARTDIR=`pwd`

mergedst()
{
    git co $SRC
    git pull
    git co $DST
    git pull
    git merge $SRC
    git push origin
    if [ `git remote | grep github` ]; then
        git push github
    fi
}

cd $RAMPDIR/ramp
mergedst

for t in $THEMES; do
    cd $RAMPDIR/ramp-theme-$t
    mergedst
done

cd $STARTDIR
