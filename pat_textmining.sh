#!/bin/sh

perl ~/Bin/MeCab/patdata_expand.pl *.cab
perl ~/Bin/MeCab/patdata_cut.pl *.txt
perl ~/Bin/MeCab/wordcount.pl *_dat.txt
perl ~/Bin/MeCab/select_word.pl
perl ~/Bin/MeCab/corresp.pl 
bayon -n 5 -c 5word.txt --idf arrt_words_tf_select_title.txt >n5clster.txt
