#!/usr/bin/perl
# umtrans.pl version 1.0 (April 8, 2001)
# Extracts translation strings from UseModWiki script.
# Run the script with one or two arguments, like:
# umtrans.pl wiki.pl > trans.pl
#   ... creates a new/empty translation table from wiki.pl
# umtrans.pl wiki.pl trans.pl > newtrans.pl
#   ... creates a new translation table using wiki.pl and an old table

if ((@ARGV < 1) || (@ARGV > 2)) {
  # Usage later
  die("Wrong number of arguments");
}

%Translate = ();
if (@ARGV == 2) {
  do (pop(@ARGV));  # Evaluate second argument and remove it
}

%seen = ();

sub trans {
  my ($string) = @_;
  my ($result);

  $result = '';
# Uncomment the next line to create a test translation table
# $result = 'X_' . $string . '_W';

  $result = $Translate{$string}  if (defined($Translate{$string}));

  return ' '  if ($seen{$string});
  $seen{$string} = 1;
  print $string . "\n" . $result . "\n";
  return ' ';
}

print '%Translate = split(\'\n\',<<END_OF_TRANSLATION);' . "\n";
foreach (<>) {
  s/T\(\'([^']+)/&trans($1)/ge;
  s/Ts\(\'([^']+)/&trans($1)/ge;
  s/T\(\"([^"]+)/&trans($1)/ge;
  s/Ts\(\"([^"]+)/&trans($1)/ge;
}

print "END_OF_TRANSLATION\n";
