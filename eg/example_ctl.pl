#!/usr/bin/env perl
use bsdconv;

$tmp=bsdconv::mktemp("score.XXXXXX");

$score=$tmp->[0];
$score_path=$tmp->[1];
unlink $score_path;
$list=bsdconv::fopen("characters_list.txt","w+");
$c=new bsdconv("utf-8:score-train:null");
if(!defined($c)){
	print bsdconv::error()."\n";
	exit;
}

$c->ctl(bsdconv::CTL_ATTACH_SCORE, $score, 0);
$c->ctl(bsdconv::CTL_ATTACH_OUTPUT_FILE, $list, 0);

open FILE, $ARGV[0];
$c->init();
while (($n = read FILE, $s, 1024) != 0) {
	$c->conv_chunk($s);
}
$c->conv_chunk_last('');

close FILE
