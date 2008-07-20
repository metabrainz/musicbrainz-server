package MusicBrainz::Server::Adapter::Tag;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT_OK = qw(PrepareForTagCloud);

use List::Util qw( min max sum );

=head1 METHODS

=head2 PrepareForTagCloud

Prepare a set of tags for display as a tag cloud

=cut

sub PrepareForTagCloud
{
    my $tags = shift;

    my @counts = sort { $a <=> $b } values %$tags;
    my $ntags  = scalar @counts;

    return unless $ntags;

	my $min = $counts[0];
	my $max = $counts[$ntags - 1];
	my $med = $ntags % 2
		? $counts[(($ntags + 1) / 2) - 1]
		: ($counts[($ntags / 2) - 1] + $counts[$ntags / 2]) / 2;
	my $sum = sum(@counts);
	my $avg = $sum / $ntags;


	my $boldthreshold = 0.25;
    my ($minsize, $maxsize) = (12, 30);
	$maxsize = $minsize + ($maxsize - $minsize) * log(1 + min(1, ($max > 0 ? $max - 1 : 0) / 20) * 1.718281828);
	if ($maxsize - $minsize < 0.2) {
		$boldthreshold = 1;
	}

	$avg /= $max;
	$med /= $max;

	$max -= $min;
	if ($max == 0) {
		$max = $min;
		$min = 0;
	}

	my $power = 1 + ($avg > $med ? -(($avg - $med) ** 0.6) : ($med - $avg) ** 0.6);

    my @ret;

	my $sizedelta = $maxsize - $minsize;
    foreach my $tag (sort keys %$tags)
    {
		my $value = (($tags->{$tag} - $min) / $max) ** $power;
        push @ret, {
            size => int($minsize + $value * $sizedelta + 0.5),
            bold => $value > $boldthreshold,
            tag => $tag,
        };
    }

    return \@ret;
}

=head1 LICENSE

This software is provided "as is", without warranty of any kind, express or
implied, including  but not limited  to the warranties of  merchantability,
fitness for a particular purpose and noninfringement. In no event shall the
authors or  copyright  holders be  liable for any claim,  damages or  other
liability, whether  in an  action of  contract, tort  or otherwise, arising
from,  out of  or in  connection with  the software or  the  use  or  other
dealings in the software.

GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt
Permits anyone the right to use and modify the software without limitations
as long as proper  credits are given  and the original  and modified source
code are included. Requires  that the final product, software derivate from
the original  source or any  software  utilizing a GPL  component, such  as
this, is also licensed under the GPL license.

=cut

1;
