use IPC::Open2;
my ($writer, $reader);
IPC::Open2::open2($reader, $writer, "cat");
select $writer;
print 'fssdhghafjghdjkldfskl';
close $writer;
select STDOUT;
#my $foo_STDOUT;
#{
#local $/;
$foo_STDOUT=<$reader>;
#}

print "|$foo_STDOUT|";
