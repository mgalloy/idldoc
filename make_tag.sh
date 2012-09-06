#!/bin/sh

TAG=$1
TAGS_OR_BRANCHES=$2


# check inputs

if test -z "$TAG"; then
  echo "TAG not specified"
  echo "Syntax: make_tag.sh TAG TAGS_OR_BRANCHES"
  echo "Example: make_tag.sh IDLDOC_3_5_0 tags"
  echo "Example: make_tag.sh IDLDOC_3_5 branches"  
  exit 1
fi

if test -z "$TAGS_OR_BRANCHES"; then
  echo "TAGS_OR_BRANCHES not specified"
  echo "Syntax: make_tag.sh TAG TAGS_OR_BRANCHES"
  echo "Example: make_tag.sh IDLDOC_3_5_0 tags"
  echo "Example: make_tag.sh IDLDOC_3_5 branches"  
  exit 1
fi

if [ $TAGS_OR_BRANCHES != "tags" ] && [ $TAGS_OR_BRANCHES != "branches" ]; then 
  echo "TAGS_OR_BRANCHES must be 'tags' or 'branches'"
  exit 1
fi

# get singular version of TAGS_OR_BRANCHES for nicer user messages
case "$TAGS_OR_BRANCHES" in
  tags) 
    SINGULAR=tag
    ;;
  branches) 
    SINGULAR=branch
    ;;
esac


echo Making sure repo is up-to-date...
svn up > /dev/null

SVN_URL=`svn info | grep "URL:" | sed -e"s/URL: //"`
SVN_ROOT=`svn info | grep "Repository Root:" | sed -e"s/Repository Root: //"`

echo Making $SINGULAR...
echo $SINGULAR URL: $SVN_ROOT/$TAGS_OR_BRANCHES/$TAG
svn cp $SVN_URL $SVN_ROOT/$TAGS_OR_BRANCHES/$TAG -m "Making $TAG $SINGULAR."

if [ $TAGS_OR_BRANCHES == "tags" ]; then 
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

  svn co $SVN_ROOT/$TAGS_OR_BRANCHES/$TAG tag_checkout
  svn propset svn:externals --file svn_externals.txt tag_checkout/src
  svn commit tag_checkout -m "Fixing externals."
  
  rm svn_externals.txt
  rm -rf tag_checkout
fi


