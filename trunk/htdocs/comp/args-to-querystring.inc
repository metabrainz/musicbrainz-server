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
	# Render all the values in the %ARGS hash as url parameters
	#
	# $Id$
	#
</%perl>
<%perl>

	my $qs = "";
	while (my ($k, $v) = each %ARGS)
	{
		defined($v) or next;
		$k = uri_escape($k);
		my @v = (ref($v) ? @$v : $v);
		$qs .= "&$k=" . uri_escape($_)
			for @v;
	}

	$qs =~ s/^&//;
	return $qs;

</%perl>

%# vi: set ts=4 sw=4 ft=mason :
