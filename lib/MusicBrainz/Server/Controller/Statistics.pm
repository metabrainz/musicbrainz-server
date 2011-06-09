package MusicBrainz::Server::Controller::Statistics;
use Moose;
use MusicBrainz::Server::Data::Statistics::ByDate;
use MusicBrainz::Server::Data::Statistics::ByName;
use MusicBrainz::Server::Data::Country;
BEGIN { extends 'MusicBrainz::Server::Controller'; }

sub statistics : Path('')
{
    my ($self, $c) = @_;

# TODO: 
#       ALTER TABLE statistic ADD CONSTRAINT statistic_pkey PRIMARY KEY (id); fails
#       for duplicate key 1
#       count.quality.release.unknown is too high

    $c->stash(
        template => 'statistics/index.tt',
        stats    => $c->model('Statistics::ByDate')->get_latest_statistics()
    );
}

sub timeline : Local
{
    my ($self, $c) = @_;

    $c->stash(
        template => 'statistics/timeline.tt',
        stats => {
            map {
                $_ => $c->model('Statistics::ByName')->get_statistic($_)
            } qw( count.artist count.release count.medium count.releasegroup count.label count.work count.recording )
        }
    )
}

sub artist_countries : Path('artist-countries')
{
    my ($self, $c) = @_;

    my $stats = $c->model('Statistics::ByDate')->get_latest_statistics();
    my $artist_country_prefix = 'count.artist.country.';
    my $artist_stats = [];
    foreach my $key 
        (sort { $stats->statistic($b) <=> $stats->statistic($a) } (keys %{ $stats->{data} })) {
       if (substr($key, 0, length($artist_country_prefix)) eq $artist_country_prefix) { 
            my $iso_code = substr($key, length($artist_country_prefix));
            my $country = $c->model('Country')->find_by_code($iso_code);
            push(@$artist_stats, ({'iso_code' => $iso_code, 'name' => $country->{name}, 'count' => $stats->statistic($key)}));
       }
    }

    $c->stash(
        template => 'statistics/artist_countries.tt',
        stats    => $artist_stats,
        date_collected => $stats->{date_collected}
    );
}

=head1 LICENSE

Copyright (C) 2011 MetaBrainz Foundation Inc.

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
