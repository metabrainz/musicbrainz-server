%# vi: set ts=2 sw=2 ft=mason :
% @_ or return;
<ul>
<%perl>

for my $bug (@_)
{
	my ($id, $desc) = $bug =~ /^(\d+) (.*)$/;
	</%perl>
	<li><% $id %> <a href="http://sourceforge.net/tracker/index.php?func=detail&amp;aid=<% $id %>&amp;group_id=19506&amp;atid=119506"><% $desc %></a></li>
	<%perl>
}

</%perl>
</ul>
