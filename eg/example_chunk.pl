#!/usr/bin/env perl
use bsdconv;

$c=new bsdconv($ARGV[0]);
if(!defined($c)){
	print bsdconv::error()."\n";
	exit;
}
$c->init();
while($s=<STDIN>){
	print $c->conv_chunk($s);
	$str.=$s;
}
print $c->conv_chunk_last('');
$i=$c->counter();
$c=undef;
print "\n=======Conversion Info=======\n";
for $k (keys %$i){
	print "$k=$i->{$k}\n";
}
