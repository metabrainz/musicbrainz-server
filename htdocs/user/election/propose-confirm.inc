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
	# This page shows a confirmation form for an autoeditor proposal.
	#
	# $Id$
	#
</%perl>
<%args>

	$username => undef

</%args>

<& /comp/sidebar-notitle, pagetitle => "Propose a Candiate for AutoEditor" &>
	<& /comp/tablebegin, title => "Propose a Candiate for AutoEditor" &>

	<table class="formstyle">
		<tr>
			<td class="instructions">
				<ul>
					<li>
						Are you sure you want to nominate the editor <& /comp/linkuser,
						name => $username &> for <& /comp/linkdoc, "AutoEditor", "AutoEditor" &>
						status?
					</li>
				</ul>
			</td>
		</tr>
	</table>

	<form method="post" action="/user/election/propose.html">
		<table class="formstyle">
			<tr>
				<td>
					<input type="hidden" name="username" value="<% $username %>" />
					<input type="hidden" name="confirm" value="1" />
					<input type="submit" name="submitvalue" value="Yes, I am sure &raquo;" />
					<input type="submit" name="submitvalue" value="Cancel" />
				</td>
			</tr>
		</table>
	</form>

	<& /comp/tableend &>

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
