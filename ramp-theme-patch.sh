RAMPDIR='C:\Users\Aleksueir\Code\TFS2013'
THEMES='canada intranet usability'
THEME=$1
PATCH=$2
STARTDIR=`pwd`

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
makepatch

for t in $THEMES; do
    cd $RAMPDIR/ramp-theme-$t
	
	if [ "$t" != "$THEME" ]; then
		patchtheme
	fi		
done

rm -f $RAMPDIR/p_auto.patch

cd $STARTDIR