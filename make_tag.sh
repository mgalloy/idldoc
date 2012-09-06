#!/bin/sh

TAG=$1
TAG_OR_BRANCHES=$2

echo Making sure repo is up-to-date...
svn up > /dev/null
	
SVN_URL=`svn info | grep "URL:" | sed -e"s/URL: //"`
SVN_ROOT=`svn info | grep "Repository Root:" | sed -e"s/Repository Root: //"`

echo Tag URL: $SVN_ROOT/$TAG_OR_BRANCHES/$TAG
svn cp $SVN_URL $SVN_ROOT/$TAG_OR_BRANCHES/$TAG -m "Making $TAG tag."

OLD_IFS=$IFS
IFS=$'\n'
SVN_EXTERNALS=( `svn propget svn:externals src` )

touch svn_externals.txt

for e in ${SVN_EXTERNALS[*]}
do
  IFS=$OLD_IFS
  EXT_PARTS=( $e )
  R=`svn info src/${EXT_PARTS[0]} | grep "Revision: " | sed -e "s/Revision: //g"`
  echo ${EXT_PARTS[0]} -r$R ${EXT_PARTS[1]} >> svn_externals.txt
  IFS=$'\n'
done
IFS=$OLD_IFS

svn co $SVN_ROOT/$TAG_OR_BRANCHES/$TAG tag_checkout
svn propset svn:externals --file svn_externals.txt tag_checkout/src
svn commit tag_checkout -m "Fixing externals."

rm svn_externals.txt
rm -rf tag_checkout