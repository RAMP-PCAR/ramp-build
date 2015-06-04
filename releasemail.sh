if [ -z $RAMPDIR ]; then
    RAMPDIR='/d/vc/rampsync'
fi
if [ -z $RAMPQCSERVER ]; then
    RAMPQCSERVER='SERVERURL'
fi
CWD=`pwd`
THEMES='core canada intranet usability fgp-int'
OUTLOOK="c:\Program Files (x86)\Microsoft Office\Office14\OUTLOOK.EXE"
OLDRELEASE=$1
NEWRELEASE=$2

if [ -z $NEWRELEASE ]; then
    echo "Usage $0 [oldrelease] [newrelease]"
    exit 1
fi

cd $RAMPDIR/ramp
git co develop
git pull
cd grunt/options
COMMITS=`git rev-list --count v$OLDRELEASE..v$NEWRELEASE`
sed -i "s/from:.*/from:\ \'v$OLDRELEASE\'/" changelog.coffee
sed -i "s/to:.*/to:\ \'v$NEWRELEASE\'/" changelog.coffee
cd ../..
echo > CHANGELOG.md
echo 'Hi Everyone:' > email.md
echo >> email.md
echo "RAMP v$NEWRELEASE has been deployed on dev." >> email.md
echo >> email.md
echo "### Dev Links" >> email.md
for T in $THEMES; do
    LINK="http://$RAMPQCSERVER/RAMP_QC/v$NEWRELEASE/$T/ramp-en.html"
    echo "- [$LINK]($LINK) " >> email.md
done
echo >> email.md
echo "### Changelog from v$OLDRELEASE to v$NEWRELEASE" >> email.md
grunt changelog
git co grunt
sed -i "1,3d" CHANGELOG.md
cat CHANGELOG.md >> email.md
echo '<!DOCTYPE html>' > $CWD/email.html
echo '<html lang="en"><head><meta charset="utf-8"><title>title</title></head>' >> $CWD/email.html
echo '<body>' >> $CWD/email.html
cat email.md | markdown2.py >> $CWD/email.html
echo '</body>' >> $CWD/email.html
echo '</html>' >> $CWD/email.html
rm email.md
rm CHANGELOG.md

cd $CWD
start email.html
if [ -e "$OUTLOOK" ]; then
    "$OUTLOOK" //c ipm.note //m "RAMP&subject=RAMP v$NEWRELEASE"
fi
