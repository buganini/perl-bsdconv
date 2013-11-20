#!/usr/bin/env perl
use bsdconv;


#print bsdconv::error();

my $c=new bsdconv($ARGV[0]);

if(!defined($c)){
	print bsdconv::error()."\n";
	exit;
}

$c->conv_file($ARGV[1], $ARGV[2]);
print $c->toString()."\n";
$i=$c->counter();
$c=undef;
for $k (keys %$i){
	print "$k=$i->{$k}\n";
}

