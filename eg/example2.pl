use bsdconv;

$c=new bsdconv('utf-8:utf-8');
$c->insert_phase('full', bsdconv::INTER, 1);
print $c->conv('test');
print "\n";
print bsdconv::codec_check(bsdconv::FROM, '_utf-8');
print "\n";
print bsdconv::codec_check(bsdconv::INTER, '_utf-8');
print "\n";

