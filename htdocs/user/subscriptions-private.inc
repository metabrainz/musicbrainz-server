%# vi: set ts=4 sw=4 ft=mason :
<%args>
$user
</%args>
<%perl>

my $uid = $user->GetId;
my $name = $user->GetName;
$m->comp("/comp/sidebar", title => "Artist Subscriptions for \"$name\"");

</%perl>

<p class="LinksRow">
	[
	<a href="/user/view.html?uid=<% $uid %>">Profile</a> | 
	<a href="/user/mod_email.html?uid=<% $uid %>&amp;url=<% uri_escape("/user/view.html?uid=$uid") %>">Send email</a> | 
    <a href="/mod/search/pre/voted.html?moderator=<% $uid %>">List Votes</a> |
	<a href="/mod/search/pre/moderator.html?moderator=<% $uid %>">List Moderations</a> |
	<a href="/mod/search/pre/moderator-failed.html?moderator=<% $uid %>">List Failed Moderations</a>
	]
</p>

<p>
	This user's list of subscribed artists is private.
</p>

<& /comp/footer &>
