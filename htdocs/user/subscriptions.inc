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
	# $Id: subscriptions-public.inc 7938 2006-06-26 06:11:53Z keschte $
	#
</%perl>
<%args>

	$user
	$info => ()
	$labels => ()
	$editors => ()
	$private => 0

</%args>
<%perl>

	my $uid = $user->GetId;
	my $name = $user->GetName;
	$m->comp("/comp/sidebar-notitle", pagetitle => "${name}'s subscriptions");

</%perl>

	<& /comp/tablebegin, title => "${name}'s subscriptions" &>

		<table class="formstyle">
			<tr class="top">
				<td colspan="2">
					<div style="border-bottom: 1px dotted #ccc; padding: 5px; margin-bottom: 5px; font-weight: bold">
						General information:
					</div></td>		
		
			<tr class="top">
				<td class="label">Contact:</td>
				<td>
					<a href="/show/user/?userid=<% $uid %>">User profile</a> |
					<a href="/user/mod_email.html?uid=<% $uid %>&amp;url=<% uri_escape("/show/user/?userid=$uid") %>">Send e-mail</a>
				</td>
			</tr>
			<tr class="top">
				<td class="label">Review:</td>
				<td>
					<a href="/mod/search/pre/voted.html?moderator=<% $uid %>">Votes</a> |
					<a href="/mod/search/pre/moderator.html?moderator=<% $uid %>">Edits</a> |
					<a href="/mod/search/pre/moderator-failed.html?moderator=<% $uid %>">Failed edits</a> |
					<a href="/mod/search/pre/moderator-deleted.html?moderator=<% $uid %>">Deleted edits</a>
				</td>
			</tr>
			
			<tr>
				<td colspan="2">&nbsp;</td>			
			</tr>			
			<tr class="top">
				<td colspan="2">
					<div style="border-bottom: 1px dotted #ccc; padding: 5px; margin-bottom: 5px; font-weight: bold">
						Artist subscriptions:
					</div></td>
			</tr>
			
			<tr class="top">
				<td class="label">&nbsp;</td>
				<td>
				
%	if ($private)
%	{

		<% $name %>'s artist subscriptions are private.

%	}
%	else
%	{


% 		my $row = 0;
% 		if (not @$info)
%		{

		No artists subscriptions found.

%		}
%		else
%		{

					<table class="artistfilter-listing">

% 			for my $artist (@$info)
%			{

						<tr class="row<% ++$row % 2 %>">
							<td class="padright">
								<& /comp/linkartist, id => $artist->{artist}, name => $artist->{name}, 
									resolution =>  $artist->{resolution}, strong => 0 &></td>
							<td>
								[&nbsp;<a href="/mod/search/pre/artist.html?artistid=<% $artist->{artist} %>">View edits</a>&nbsp;]</td>
						</tr>

% 			}

					</table>

% 		}
% 	}

				</td>
			</tr>


			<tr>
				<td colspan="2">&nbsp;</td>			
			</tr>			
			<tr class="top">
				<td colspan="2">
					<div style="border-bottom: 1px dotted #ccc; padding: 5px; margin-bottom: 5px; font-weight: bold">
						Label subscriptions:
					</div></td>
			</tr>
			
			<tr class="top">
				<td class="label">&nbsp;</td>
				<td>
				
%	if ($private)
%	{

		<% $name %>'s label subscriptions are private.

%	}
%	else
%	{


% 		my $row = 0;
% 		if (not @$labels)
%		{

		No label subscriptions found.

%		}
%		else
%		{

					<table class="artistfilter-listing">

% 			for my $label (@$labels)
%			{

						<tr class="row<% ++$row % 2 %>">
							<td class="padright">
								<& /comp/linklabel, id => $label->{label}, name => $label->{name}, 
									resolution =>  $label->{resolution}, strong => 0 &></td>
							<td>
								[&nbsp;<a href="/mod/search/pre/label.html?labelid=<% $label->{label} %>">View edits</a>&nbsp;]</td>
						</tr>

% 			}

					</table>

% 		}
% 	}

				</td>
			</tr>

			<tr>
				<td colspan="2">&nbsp;</td>			
			</tr>			
			<tr class="top">
				<td colspan="2">
					<div style="border-bottom: 1px dotted #ccc; padding: 5px; margin-bottom: 5px; font-weight: bold">
						Editor subscriptions:
					</div></td>
			</tr>
			
			<tr class="top">
				<td class="label">&nbsp;</td>
				<td>
				
%	if ($private)
%	{

		<% $name %>'s editor subscriptions are private.

%	}
%	else
%	{


% 		my $row = 0;
% 		if (not @$editors)
%		{

		No editor subscriptions found.

%		}
%		else
%		{

					<table class="artistfilter-listing">

% 			for my $editor (@$editors)
%			{

						<tr class="row<% ++$row % 2 %>">
							<td class="padright">
								<& /comp/linkuser, id => $editor->{subscribededitor}, name => $editor->{name}, 
									resolution =>  $editor->{resolution}, strong => 0 &></td>
							<td>
								[&nbsp;<a href="/mod/search/pre/editor.html?userid=<% $editor->{subscribededitor} %>">View edits</a>&nbsp;]</td>
						</tr>

% 			}

					</table>

% 		}
% 	}

				</td>
			</tr>


		</table>

	<& /comp/tableend &>

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
