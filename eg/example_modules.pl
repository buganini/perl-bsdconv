use bsdconv;

print bsdconv::module_check(bsdconv::FROM, '_utf-8');
print "\n";
print bsdconv::module_check(bsdconv::INTER, '_utf-8');
print "\n";

print "Filter\n";
$a=bsdconv::modules_list(bsdconv::FILTER);
print join(", ", @$a);
print "\n\n";

print "From\n";
$a=bsdconv::modules_list(bsdconv::FROM);
print join(", ", @$a);
print "\n\n";

print "Inter\n";
$a=bsdconv::modules_list(bsdconv::INTER);
print join(", ", @$a);
print "\n\n";

print "To\n";
$a=bsdconv::modules_list(bsdconv::TO);
print join(", ", @$a);
print "\n\n";

