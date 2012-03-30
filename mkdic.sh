#!/bin/sh
BINDIR=/Users/10005239/Bin/MeCab
TERMDIR=/Users/10005239/Bin/MeCab/Dic
DICDIR=/usr/local/lib/mecab/dic/naist-pat/
USERDIC=userdic.dic
TERMTXT=maketerm.txt
DELLTXT=delword.txt
PHYSICTXT=physicdic.txt

cd $TERMDIR
#perl $BINDIR/make_userdic.pl $PHYSICTXT PHYSICALWORD >userdic.csv
perl $BINDIR/make_userdic.pl PHYSICALWORD $PHYSICTXT $TERMTXT >userdic.csv
#perl $BINDIR/make_userdic.pl $TERMTXT PHYSICALWORD >>userdic.csv
perl $BINDIR/make_userdic.pl DELLWORD $DELLTXT >>userdic.csv
sudo /usr/local/libexec/mecab/mecab-dict-index -d $DICDIR -t utf-8 -f utf-8 -u ./userdic.dic userdic.csv
