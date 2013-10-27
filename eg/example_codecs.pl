use bsdconv;

$c=new bsdconv('utf-8:utf-8');
print $c->toString();
print "\n";
print $c->conv('test');
print "\n";
print bsdconv::codec_check(bsdconv::FROM, '_utf-8');
print "\n";
print bsdconv::codec_check(bsdconv::INTER, '_utf-8');
print "\n";

print "From\n";
$a=bsdconv::codecs_list(bsdconv::FROM);
print join(", ", @$a);
print "\n\n";

print "Inter\n";
$a=bsdconv::codecs_list(bsdconv::INTER);
print join(", ", @$a);
print "\n\n";

print "To\n";
$a=bsdconv::codecs_list(bsdconv::TO);
print join(", ", @$a);
print "\n\n";

