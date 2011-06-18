package MusicBrainz::Server::Controller::Statistics;
use Moose;
use MusicBrainz::Server::Data::Statistics::ByDate;
use MusicBrainz::Server::Data::Statistics::ByName;
use MusicBrainz::Server::Data::Country;
use List::UtilsBy qw( rev_nsort_by );

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
            } qw( count.artist count.release count.medium count.releasegroup count.label count.work count.recording count.edit count.edit.open count.edit.perday count.edit.perweek count.vote count.vote.perday count.vote.perweek count.editor count.editor.editlastweek count.editor.votelastweek count.editor.activelastweek )
        }
    )
}

sub artist_countries : Path('artist-countries')
{
    my ($self, $c) = @_;

    my $stats = $c->model('Statistics::ByDate')->get_latest_statistics();
    my $artist_country_prefix = 'count.artist.country';
    my $artist_stats = [];
    my %countries = map { $_->iso_code => $_ } $c->model('Country')->get_all();
    foreach my $stat_name
        (rev_nsort_by { $stats->statistic($_) } $stats->statistic_names) {
       if (my ($iso_code) = $stat_name =~ /^$artist_country_prefix\.(.*)$/) { 
            push(@$artist_stats, ({'entity' => $countries{$iso_code}, 'count' => $stats->statistic($stat_name)}));
       }
    }

    $c->stash(
        template => 'statistics/artist_countries.tt',
        stats    => $artist_stats,
        date_collected => $stats->{date_collected}
    );
}

sub release_countries : Path('release-countries')
{
    my ($self, $c) = @_;

    my $stats = $c->model('Statistics::ByDate')->get_latest_statistics();
    my $release_country_prefix = 'count.release.country';
    my $release_stats = [];
    my %countries = map { $_->iso_code => $_ } $c->model('Country')->get_all();
    foreach my $stat_name
        (rev_nsort_by { $stats->statistic($_) } $stats->statistic_names) {
       if (my ($iso_code) = $stat_name =~ /^$release_country_prefix\.(.*)$/) { 
            push(@$release_stats, ({'entity' => $countries{$iso_code}, 'count' => $stats->statistic($stat_name)}));
       }
    }

    $c->stash(
        template => 'statistics/release_countries.tt',
        stats    => $release_stats,
        date_collected => $stats->{date_collected}
    );
}

sub label_countries : Path('label-countries')
{
    my ($self, $c) = @_;

    my $stats = $c->model('Statistics::ByDate')->get_latest_statistics();
    my $label_country_prefix = 'count.label.country';
    my $label_stats = [];
    my %countries = map { $_->iso_code => $_ } $c->model('Country')->get_all();
    foreach my $stat_name
        (rev_nsort_by { $stats->statistic($_) } $stats->statistic_names) {
       if (my ($iso_code) = $stat_name =~ /^$label_country_prefix\.(.*)$/) { 
            push(@$label_stats, ({'entity' => $countries{$iso_code}, 'count' => $stats->statistic($stat_name)}));
       }
    }

    $c->stash(
        template => 'statistics/label_countries.tt',
        stats    => $label_stats,
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
