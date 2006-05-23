<%perl>
	# -----------------------------------------------------------------------------
	#                               Musicbrainz.org
	#                        Copyright (c) 2001 Robert Kaye
	# -----------------------------------------------------------------------------
	#  This software is provided "as is", without warranty of any kind, express or
	#  implied, including  but not limited  to the warranties of  merchantability,
	#  fitness for a particular purpose and noninfringement. In no event shall the
	#  authors or  copyright  holders be  liable for any claim,  damages or  other
	#  liability, whether  in an  action of  contract, tort  or otherwise, arising
	#  from,  out of  or in  connection with  the software or  the  use  or  other
	#  dealings in the software.
	#
	#  GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt
	#  Permits anyone the right to use and modify the software without limitations
	#  as long as proper  credits are given  and the original  and modified source
	#  code are included. Requires  that the final product, software derivate from
	#  the original  source or any  software  utilizing a GPL  component, such  as
	#  this, is also licensed under the GPL license.
	# -----------------------------------------------------------------------------
	#
	# Summary:
	# -----------------------------------------------------------------------------
	# This page shows a the artist subscriptions of a given user.
	#
	#
	# $Id$
	#
</%perl>
<%args>

	$user
	$info

</%args>
<%perl>

	# return $m->comp("/comp/error", "Public subscription lists are not released until Tue Mar 15 20:30:00 2005 UTC", 1, 1)
	# 	unless time() >= 1110918600;

	my $uid = $user->GetId;
	my $name = $user->GetName;
	$m->comp("/comp/sidebar", title => "Artist Subscriptions for \"$name\"");

</%perl>

	<p class="LinksRow">
		[
		<a href="/user/view.html?uid=<% $uid %>">Profile</a> |
		<a href="/user/mod_email.html?uid=<% $uid %>&amp;url=<% uri_escape("/user/view.html?uid=$uid") %>">Send E-mail</a> |
		<a href="/mod/search/pre/voted.html?moderator=<% $uid %>">Votes</a> |
		<a href="/mod/search/pre/moderator.html?moderator=<% $uid %>">Edits</a> |
		<a href="/mod/search/pre/moderator-failed.html?moderator=<% $uid %>">Failed Edits</a> |
		<a href="/mod/search/pre/moderator-deleted.html?moderator=<% $uid %>">Deleted Edits</a>
		]
	</p>

% 	my $row = 0;
% 	my @colours = ('#fff', '#ffe1b7');

<center>

	<table class="SpacedColumns" style="width: 30em">
		<caption>Subscribed Artists</caption>
		<col />
		<col style="width: 4em" />

% 	for my $artist (@$info)
%	{

		<tr style="background-color: <% $colours[++$row % @colours] %>">
			<td><a href="/showartist.html?artistid=<% $artist->{artist} %>"
				><% $artist->{name} %></a></td>
			<td nowrap>[
				<a href="/mod/search/pre/artist.html?artistid=<% $artist->{artist} %>">Edits</a>
			]</td>
		</tr>

% 	}

	</table>

</center>

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
