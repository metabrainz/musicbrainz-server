%# vi: set ts=2 sw=2 ft=mason :
<%perl>

my $qs = "";
while (my ($k, $v) = each %ARGS)
{
	defined($v) or next;
	$k = url_escape($k);
	my @v = (ref($v) ? @$v : $v);
	$qs .= "&$k=" . url_escape($_)
		for @v;
}

$qs =~ s/^&//;
return $qs;

</%perl>
