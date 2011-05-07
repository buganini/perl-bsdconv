#!/usr/bin/env perl
use bsdconv;

$cd=bsdconv::create($ARGV[0]);
if(!defined($cd)){ 
	print bsdconv::error()."\n";
	exit; 
}
bsdconv::init($cd);
while($s=<STDIN>){
	print bsdconv::conv_chunk($cd,$s);
	$str.=$s;
}
print bsdconv::conv_chunk_last($cd,'');
$i=bsdconv::info($cd);
bsdconv::destroy($cd);
print "\n=======Conversion Info=======\n";
for $k (keys %$i){
	print "$k=$i->{$k}\n";
}
