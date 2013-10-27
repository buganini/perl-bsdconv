use bsdconv;

$sin="utf-8:utf-8,ascii";
$sout=bsdconv::insert_phase($sin, "upper", bsdconv::INTER, 1);
print $sout."\n";

$sin=$sout;
$sout=bsdconv::replace_phase($sin, "full", bsdconv::INTER, 1);
print $sout."\n";

$sin=$sout;
$sout=bsdconv::replace_codec($sin, "big5", 2, 1);
print $sout."\n";

$sin=$sout;
$sout=bsdconv::insert_codec($sin, "ascii", 0, 1);
print $sout."\n";
