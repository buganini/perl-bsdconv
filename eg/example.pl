#!/usr/bin/env perl
use bsdconv;


#print bsdconv::error();

my $c=new bsdconv($ARGV[0]);

if(!defined($c)){
	print bsdconv::error()."\n";
	exit;
}

$str='';
while($s=<STDIN>){
	$str.=$s;
}
print $c->conv($str);
$i=$c->counter();
$c=undef;
print "\n=======Conversion Info=======\n";
for $k (keys %$i){
	print "$k=$i->{$k}\n";
}

