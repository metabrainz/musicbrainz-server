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
	# This report lists tracks which do not conform to FeaturingArtistStyle.
	#
	# $Id$
	#
</%perl>

<& /comp/sidebar-notitle, pagetitle => "Track names which do not conform to FeaturingArtistStyle" &>

<%perl>

	$ARGS{"report_title"} =
		qq!Track names which do not conform to FeaturingArtistStyle!;

	$ARGS{"report_text"} =
		qq!	This report lists broken tracks containing featuring artists that do not
			follow the style guide. For some tracks (those with a <em>Suggest</em>
			link) a suggestion exists which is used as a default in the
			<em>edit track</em> dialog. You may still need the <em>Guess Case</em>
			button or manual intervention, however.!;

	$m->comp("/reports/show_tracks.inc", %ARGS);

</%perl>

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
