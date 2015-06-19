RAMPDIR='C:\Users\Aleksueir\Code\TFS2013'
THEMES='canada intranet usability fgp-int'
THEME=$1
PATCH=$2
BRANCH=$3
STARTDIR=`pwd`

#Usage:
#ramp-theme-patch [theme-name] [patch command] [branch name]
#
#theme-name is the name of the theme where the changes are
#patch command is indicating changes to propagate; can be something like "-1 <sha>" for a single commit patch or "master" for changes from the current against master
makepatch()
{
    git format-patch $PATCH --stdout > $RAMPDIR/p_auto.patch
}

patchtheme()
{
    git am --signoff $RAMPDIR/p_auto.patch
}

rm -f $RAMPDIR/p_auto.patch

cd $RAMPDIR/ramp-theme-$THEME
git co $BRANCH
makepatch

for t in $THEMES; do
    cd $RAMPDIR/ramp-theme-$t
	
	if [ "$t" != "$THEME" ]; then
        git co $BRANCH
		patchtheme
	fi		
done

rm -f $RAMPDIR/p_auto.patch

cd $STARTDIR
