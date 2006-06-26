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
	# This report lists tracks which might have a wrong encoding set.
	#
	# $Id$
	#
</%perl>
<& /comp/sidebar-notitle, pagetitle => "Tracks which are probably encoded using the wrong character set" &>

<%perl>

	$ARGS{"report_title"} =
		qq!Tracks which are probably encoded using the wrong character set!;

	$ARGS{"report_text"} = sprintf
		qq!	When data is imported from FreeDB, it is meant to be in the iso-8859-1
			("Latin-1") character set. However, if the data was actually in a
			different character set, for example the Chinese "Big5" set, then the data
			which ends up in MusicBrainz is corrupted. It is not worthless, though,
			because with a little effort the correct character set can be
			deduced, and the existing data converted into the correct form.

			All tracks which look like they might have been encoded using the wrong
			character set are listed below. We are looking specifically for tracks
			which only contain characters from the latin-1 character set, but which
			do not contain any of A-Z a-z 0-9. Finally we ignore a few track names
			which fit this category but which occur very often (e.g. ".", "?", "???" etc.)

			For more information, please read the %s.!

		, $m->scomp("/comp/linkdoc", "MisencodingFAQ", "Misencoding FAQ");

	$m->comp("/reports/show_tracks.inc", %ARGS);

</%perl>

<& /comp/footer &>

%# vi: set ts=4 sw=4 ft=mason :
