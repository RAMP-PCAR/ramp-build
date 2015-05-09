if [ -z $RAMPDIR ]; then
    RAMPDIR='/d/vc/rampsync'
fi
if [ -z $RAMPDOCS ]; then
    RAMPDOCS='/c/users/alym/vc/rampdocs'
fi
CWD=`pwd`
OLDRELEASE=$1
NEWRELEASE=$2
OLDNAME=$3
CODENAME=$4
RELEASEDATE=$5
LINKVER=`echo $NEWRELEASE | sed -e "s/\./_/g"`

if [ -z $RELEASEDATE ]; then
    echo "Usage $0 [oldrelease] [newrelease] '[old code name]' '[code name]' '[release date yyyy-mm-dd]'"
    exit 1
fi

eval `python parsever.py $NEWRELEASE`

cd $RAMPDIR/ramp
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
sed -i "1,3d" CHANGELOG.md

cd $RAMPDOCS
git co develop
# git pull
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
cat $RAMPDIR/ramp/CHANGELOG.md >> v$NEWRELEASE-en.md
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
cat dl-table.txt | sed -e "s/{VER}/$NEWRELEASE/g" -e "s/{LINKVER}/$LINKVER/g" > $NEWRELEASE-table.txt
sed -i "${LINE}r $NEWRELEASE-table.txt" download-en.md
rm $NEWRELEASE-table.txt

if grep "$TITLE" index-en.md; then
    LINE=`grep -n "$TITLE" index-en.md | cut -d : -f 1`
    let LINE+=4
else
    LINE=`grep -n '<a name="version-list"></a>' index-en.md | cut -d : -f 1`
    let LINE+=1
fi
sed -i "${LINE}i | v$NEWRELEASE | $RELEASEDATE | [Release Notes]({{ BASE_PATH }}/versions/v$NEWRELEASE-en.html) | [Download]({{ BASE_PATH }}/versions/download-en.html#v$LINKVER) |" index-en.md

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
rm $NEWRELEASE-table.txt

cd ../api
LINE=`grep -n '# API Reference {#wb-cont}' index-en.md | cut -d : -f 1`
let LINE+=4
sed -i "${LINE}i | v$NEWRELEASE - $CODENAME | [Link](v$NEWRELEASE/yuidoc/) |" index-en.md

cd ../docs/archive
LINE=`grep -n '# Archive {#wb-cont}' index-en.md | cut -d : -f 1`
let LINE+=4
sed -i "${LINE}i | v$OLDRELEASE - $OLDNAME | [Link]($OLDRELEASE/index-en.html) | [Link](/api/v$OLDRELEASE/yuidoc/) |" index-en.md
mkdir -p "$OLDRELEASE/assets"
echo
echo "Copying old docs to $OLDRELEASE"
cp -v ../*.md "$OLDRELEASE"
echo
echo "Copying image assets $OLDRELEASE/assets/images"
cp -rv ../../assets/images "$OLDRELEASE/assets"
cd $OLDRELEASE
sed -i "s/..\/assets\/images/assets\/images/g" *.md
sed -i "s/layout:\ index-secmenu-en/layout:\ index-secmenu-$OLDRELEASE-en/g" *.md
cd $RAMPDOCS/_layouts
cp index-secmenu-en.html "index-secmenu-$OLDRELEASE-en.html"
sed -i "s/RAMP_documentation_secemenu/RAMP_documentation_secemenu_$OLDRELEASE/g" "index-secmenu-$OLDRELEASE-en.html"
cd ../_includes/RAMP
cp RAMP_documentation_secemenu.html "RAMP_documentation_secemenu_${OLDRELEASE}.html"


echo $MAJOR $MINOR $PATCH
