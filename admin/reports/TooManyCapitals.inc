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
	# This report lists track names which consist of too many uppercase letters.
	#
	# $Id$
	#
</%perl>

<& /comp/sidebar-notitle, pagetitle => "Tracks with too many uppercase letters" &>

<%perl>

	$ARGS{"report_title"} =
		qq!Tracks with too many uppercase letters!;

	$ARGS{"report_text"} =
		qq!	All tracks which contain at least five sequential uppercase
			characters are listed below:!;

	$m->comp("/reports/show_tracks.inc", %ARGS);

</%perl>

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
