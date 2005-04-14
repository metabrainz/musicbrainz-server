%# vi: set ts=4 sw=4 ft=mason :
<%args>
$user
$info
</%args>
<%perl>

return $m->comp("/comp/error", "Public subscription lists are not released until Tue Mar 15 20:30:00 2005 UTC", 1, 1)
	unless time() >= 1110918600;

my $uid = $user->GetId;
my $name = $user->GetName;
$m->comp("/comp/sidebar", title => "Artist Subscriptions for \"$name\"");

</%perl>

<p class="LinksRow">
	[
	<a href="/user/view.html?uid=<% $uid %>">Profile</a> | 
	<a href="/user/mod_email.html?uid=<% $uid %>&amp;url=<% uri_escape("/user/view.html?uid=$uid") %>">Send email</a> | 
    <a href="/mod/search/pre/voted.html?moderator=<% $uid %>">Votes</a> |
	<a href="/mod/search/pre/moderator.html?moderator=<% $uid %>">Moderations</a> |
	<a href="/mod/search/pre/moderator-failed.html?moderator=<% $uid %>">Failed Moderations</a> |
	<a href="/mod/search/pre/moderator-deleted.html?moderator=<% $uid %>">Deleted Moderations</a>
	]
</p>

% my $row = 0;
% my @colours = ('#fff', '#ffe1b7');

<center>
	<table class="SpacedColumns" style="width: 30em">
		<caption>Subscribed Artists</caption>
		<col>
		<col style="width: 4em">
% for my $artist (@$info) {
		<tr style="background-color: <% $colours[++$row % @colours] %>">
			<td style="padding-right: 2em"><a href="/showartist.html?artistid=<% $artist->{artist} %>"
				><% $artist->{name} %></a></td>
			<td style="text-align: center" nowrap>[
				<a href="/mod/search/pre/artist.html?artistid=<% $artist->{artist} %>">Mods</a>
			]</td>
		</tr>
% }
	</table>

</center>

<& /comp/footer &>
