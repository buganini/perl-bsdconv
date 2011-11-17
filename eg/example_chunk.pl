#!/usr/bin/env perl
use bsdconv;

$c=new bsdconv($ARGV[0]);
if(!defined($c)){ 
	print bsdconv::error()."\n";
	exit; 
}
$c->insert_phase('normal_score',bsdconv::INTER,1);
$c->init();
while($s=<STDIN>){
	print $c->conv_chunk($s);
	$str.=$s;
}
print $c->conv_chunk_last('');
$i=$c->info();
$c=undef;
print "\n=======Conversion Info=======\n";
for $k (keys %$i){
	print "$k=$i->{$k}\n";
}
