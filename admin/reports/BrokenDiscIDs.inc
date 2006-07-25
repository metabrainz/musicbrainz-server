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
	# This report lists releases with where the DiscIDs do not match
	# the other attributes of the release (track numbers, lenghts, ...)
	#
	# $Id$
	#
</%perl>
<& /comp/sidebar-notitle, pagetitle => qq!Releases with "Broken" Disc IDs! &>

<%perl>

	$ARGS{"report_title"} =
		qq!Releases with "Broken" Disc IDs!;

	$ARGS{"report_text"} =
		qq! This report identifies releases with disc IDs, where the tracks
			on the release do not match with the discID.

			For example, if the disc ID says that there are four tracks, then
			this report checks that the release has four tracks, and that the
			first track is track 1, and the last track is track 4. Note that
			it <em>doesn't</em> check all the intervening track numbers; for example,
			if the tracks on the release were numbered 1, 2, 2, 4, then this
			report would <em>not</em> detect that.  However by using both
			this report and the <a href="/reports/generated/DuplicateTrackNumbers">duplicate track numbers</a>
			report it should be possible to identify and fix all track/disc ID problems.!;

	$m->comp("/reports/show_albums.inc", %ARGS);

</%perl>

<& /comp/footer &>
