%# vi: set ts=4 sw=4 ft=mason :
<%args>
$modname => undef
</%args>
<& /comp/sidebar, title => "Propose an Auto-Moderator" &>

<p>
	Are you sure you want to put
	<a href="/user/view.html?modname=<% uri_escape($modname) %>"><% $modname %></a>
	forward for auto-moderator status?
</p>

<form method="post" action="/user/election/propose.html">
	<p>
		<input type="hidden" name="modname" value="<% $modname %>">
		<input type="hidden" name="confirm" value="1">
		<input type="submit" value="Yes, I'm sure">
	</p>
</form>

<p>
	If not, <a href="javascript:history.back()">go back</a>
	to the user's profile page.
</p>

<& /comp/footer &>
