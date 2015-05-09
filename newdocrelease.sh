if [ -z $RAMPDIR ]; then
    RAMPDIR='/d/vc/rampsync'
fi
if [ -z $RAMPDOCS ]; then
    RAMPDOCS='/c/users/alym/vc/rampdocs'
fi
CWD=`pwd`
OLDRELEASE=$1
NEWRELEASE=$2
CODENAME=$3
RELEASEDATE=$4

if [ -z $RELEASEDATE ]; then
    echo "Usage $0 [oldrelease] [newrelease] '[code name]' '[release date yyyy-mm-dd]'"
    exit 1
fi

eval `python parsever.py $NEWRELEASE`

cd $RAMPDIR/RAMP
git co develop
git pull
cd grunt/options
COMMITS=`git rev-list --count v$OLDRELEASE..v$NEWRELEASE`
sed -i "s/from:.*/from:\ \'v$OLDRELEASE\'/" changelog.coffee
sed -i "s/to:.*/to:\ \'v$NEWRELEASE\'/" changelog.coffee
cd ../..
rm CHANGELOG.md
grunt changelog
git co grunt
cat CHANGELOG.md

cd $RAMPDOCS
git co develop
git pull
cd versions
cp version-template.txt v$NEWRELEASE-en.md
TITLE="v$NEWRELEASE - $CODENAME - Release Notes"
sed -i "s/title:.*/title:\ $TITLE/" v$NEWRELEASE-en.md
echo "# $TITLE {#wb-cont}" >> v$NEWRELEASE-en.md
echo "" >> v$NEWRELEASE-en.md
echo '<div class="toc"></div>' >> v$NEWRELEASE-en.md
echo "" >> v$NEWRELEASE-en.md
echo "* **Release Date:** $RELEASEDATE" >> v$NEWRELEASE-en.md
echo "" >> v$NEWRELEASE-en.md
cat $RAMPDIR/RAMP/CHANGELOG.md >> v$NEWRELEASE-en.md
echo "" >> v$NEWRELEASE-en.md
echo "## Details" >> v$NEWRELEASE-en.md
echo "" >> v$NEWRELEASE-en.md
echo "**Number of Commits:** $COMMITS" >> v$NEWRELEASE-en.md

TITLE="## Version $MAJOR - $CODENAME"
if grep "$TITLE" download-en.md; then
    LINE=`grep -n "$TITLE" download-en.md | cut -d : -f 1`
    let LINE+=3
else
    LINE=`grep -n '<a name="version-list"></a>' download-en.md | cut -d : -f 1`
    let LINE+=1
fi
cat dl-table.txt | sed -e "s/{VER}/$NEWRELEASE/g" > $NEWRELEASE-table.txt
sed -i "${LINE}r $NEWRELEASE-table.txt" download-en.md

if grep "$TITLE" index-en.md; then
    LINE=`grep -n "$TITLE" index-en.md | cut -d : -f 1`
    let LINE+=4
else
    LINE=`grep -n '<a name="version-list"></a>' index-en.md | cut -d : -f 1`
    let LINE+=1
fi
sed -i "${LINE}i | v$NEWRELEASE | $RELEASEDATE | [Release Notes]({{ BASE_PATH }}/versions/v$NEWRELEASE-en.html) | [Download]({{ BASE_PATH }}/versions/download-en.html#v$NEWRELEASE) |" index-en.md

cd ../demos
if grep "$TITLE" index-en.md; then
    LINE=`grep -n "$TITLE" index-en.md | cut -d : -f 1`
    let LINE+=1
else
    LINE=`grep -n '<div class="toc"></div>' index-en.md | cut -d : -f 1`
    let LINE+=1
fi
cat demo-table.txt | sed -e "s/{VER}/$NEWRELEASE/g" > $NEWRELEASE-table.txt
sed -i "${LINE}r $NEWRELEASE-table.txt" index-en.md

cd ../api
LINE=`grep -n '# API Reference {#wb-cont}' index-en.md | cut -d : -f 1`
let LINE+=4
sed -i "${LINE}i | v$NEWRELEASE - $CODENAME | [Link](v$NEWRELEASE/yuidoc/) |" index-en.md

echo $MAJOR $MINOR $PATCH
