%# vi: set ts=2 sw=2 ft=mason :
<%perl>

my $qs = "";
while (my ($k, $v) = each %ARGS)
{
	defined($v) or next;
	$k = uri_escape($k);
	my @v = (ref($v) ? @$v : $v);
	$qs .= "&$k=" . uri_escape($_)
		for @v;
}

$qs =~ s/^&//;
return $qs;

</%perl>
