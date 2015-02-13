RAMPDIR='c:\users\alym\vc\rampsync'
THEMES='canada intranet usability'
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
    git push github
}

cd $RAMPDIR/ramp
mergedst

for t in $THEMES; do
    cd $RAMPDIR/ramp-theme-$t
    mergedst
done

cd $STARTDIR
