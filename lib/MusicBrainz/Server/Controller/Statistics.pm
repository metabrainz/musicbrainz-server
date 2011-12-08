package MusicBrainz::Server::Controller::Statistics;
use Moose;
use MusicBrainz::Server::Data::Statistics::ByDate;
use MusicBrainz::Server::Data::Statistics::ByName;
use MusicBrainz::Server::Data::Country;
use List::UtilsBy qw( rev_nsort_by );
use Date::Calc qw( Today Add_Delta_Days Date_to_Time );

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

sub timeline : Path('timeline/main')
{
    my ($self, $c) = @_;

    my @stats = qw( count.artist count.release count.medium count.releasegroup count.label count.work count.recording count.edit count.edit.open count.edit.perday count.edit.perweek count.vote count.vote.perday count.vote.perweek count.editor count.editor.editlastweek count.editor.votelastweek count.editor.activelastweek );
    $c->stash(
        template => 'statistics/timeline.tt',
        stats => \@stats
    )
}

sub timeline_redirect : Path('timeline')
{
    my ($self, $c) = @_;
    $c->response->redirect($c->uri_for("/statistics/timeline/main"), 303);
}

sub individual_timeline : Path('timeline') Args(1)
{
    my ($self, $c, $stat) = @_;

    my @stats = ($stat);
    $c->stash(
        template => 'statistics/timeline.tt',
        stats => \@stats,
        show_all => 1,
    )
}

sub dataset : Local Args(1)
{
    my ($self, $c, $dataset) = @_;

    $c->res->content_type('application/json; charset=utf-8');
    my $tomorrow = Date_to_Time(Add_Delta_Days(Today(1), 1), 0, 0, 0);
    $c->res->headers->expires($tomorrow);
    $c->stash(
        template => 'statistics/dataset.tt',
        statistic => $c->model('Statistics::ByName')->get_statistic($dataset)
    )
}

sub countries : Local
{
    my ($self, $c) = @_;

    my $stats = $c->model('Statistics::ByDate')->get_latest_statistics();
    my $country_stats = [];
    my $artist_country_prefix = 'count.artist.country';
    my $release_country_prefix = 'count.release.country';
    my $label_country_prefix = 'count.label.country';
    my %countries = map { $_->iso_code => $_ } $c->model('Country')->get_all();
    foreach my $stat_name
        (rev_nsort_by { $stats->statistic($_) } $stats->statistic_names) {
       if (my ($iso_code) = $stat_name =~ /^$artist_country_prefix\.(.*)$/) { 
	    my $release_stat = $stat_name;
	    my $label_stat = $stat_name;
	    $release_stat =~ s/$artist_country_prefix/$release_country_prefix/;
	    $label_stat =~ s/$artist_country_prefix/$label_country_prefix/;
            push(@$country_stats, ({'entity' => $countries{$iso_code}, 'artist_count' => $stats->statistic($stat_name), 'release_count' => $stats->statistic($release_stat), 'label_count' => $stats->statistic($label_stat)}));
       }
    }

    $c->stash(
        template => 'statistics/countries.tt',
        stats    => $country_stats,
        date_collected => $stats->{date_collected}
    );
}

sub languages_scripts : Path('languages-scripts')
{
    my ($self, $c) = @_;

    my $stats = $c->model('Statistics::ByDate')->get_latest_statistics();
    my $language_stats = [];
    my $script_stats = [];
    my $language_prefix = 'count.release.language';
    my $script_prefix = 'count.release.script';
    my %languages = map { $_->iso_code_3t => $_ } $c->model('Language')->get_all();
    my %scripts = map { $_->iso_code => $_ } $c->model('Script')->get_all();
    foreach my $stat_name
        (rev_nsort_by { $stats->statistic($_) } $stats->statistic_names) {
       if (my ($iso_code_3t) = $stat_name =~ /^$language_prefix\.(.*)$/) { 
            push(@$language_stats, ({'entity' => $languages{$iso_code_3t}, 'count' => $stats->statistic($stat_name)}));
       }
       if (my ($iso_code) = $stat_name =~ /^$script_prefix\.(.*)$/) { 
            push(@$script_stats, ({'entity' => $scripts{$iso_code}, 'count' => $stats->statistic($stat_name)}));
       }
    }

    $c->stash(
        template => 'statistics/languages_scripts.tt',
        language_stats  => $language_stats,
        script_stats    => $script_stats,
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
