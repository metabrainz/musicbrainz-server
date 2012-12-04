package MusicBrainz::Server::Controller::Statistics;
use Moose;
use MusicBrainz::Server::Data::Statistics::ByDate;
use MusicBrainz::Server::Data::Statistics::ByName;
use MusicBrainz::Server::Data::Country;
use MusicBrainz::Server::Translation::Statistics qw(l ln);
use List::AllUtils qw( sum );
use List::UtilsBy qw( rev_nsort_by sort_by );
use Date::Calc qw( Today Add_Delta_Days Date_to_Time );

use aliased 'MusicBrainz::Server::EditRegistry';

BEGIN { extends 'MusicBrainz::Server::Controller'; }

sub statistics : Path('')
{
    my ($self, $c) = @_;

    my $latest_stats = try_fetch_latest_statistics($c);

# TODO: 
#       ALTER TABLE statistic ADD CONSTRAINT statistic_pkey PRIMARY KEY (id); fails
#       for duplicate key 1
#       count.quality.release.unknown is too high
    my %statuses = map { $_->id => $_ } $c->model('ReleaseStatus')->get_all();
    my %packagings = map { $_->id => $_ } $c->model('ReleasePackaging')->get_all();
    my %primary_types = map { $_->id => $_ } $c->model('ReleaseGroupType')->get_all();
    my %secondary_types = map { $_->id => $_ } $c->model('ReleaseGroupSecondaryType')->get_all();
    my @work_types = sort_by { $_->l_name } $c->model('WorkType')->get_all();

    $c->stash(
        template => 'statistics/index.tt',
        statuses => \%statuses,
        packagings => \%packagings,
        primary_types => \%primary_types,
        secondary_types => \%secondary_types,
        work_types => \@work_types,
        stats => $latest_stats
    );
}

sub timeline : Path('timeline/main')
{
    my ($self, $c) = @_;

    my @stats = qw( count.artist count.release count.medium count.releasegroup count.label count.work count.recording count.edit count.edit.open count.edit.perday count.edit.perweek count.vote count.vote.perday count.vote.perweek count.editor count.editor.editlastweek count.editor.votelastweek count.editor.activelastweek count.coverart count.release.has_caa );
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

    my $stats = try_fetch_latest_statistics($c);
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

sub coverart : Local
{
    my ($self, $c) = @_;

    my $stats = try_fetch_latest_statistics($c);

    my $release_type_stats = [];
    my $release_status_stats = [];
    my $release_format_stats = [];
    my $type_stats = [];
    my $per_release_stats = [];

    foreach my $stat_name
        (rev_nsort_by { $stats->statistic($_) } $stats->statistic_names) {
        if (my ($type) = $stat_name =~ /^count\.release\.type\.(.*)\.has_coverart$/) {
            push(@$release_type_stats, ({'stat_name' => $stat_name, 'type' => $type}));
        }
        if (my ($status) = $stat_name =~ /^count\.release\.status\.(.*)\.has_coverart$/) {
            push(@$release_status_stats, ({'stat_name' => $stat_name, 'status' => $status}));
        }
        if (my ($format) = $stat_name =~ /^count\.release\.format\.(.*)\.has_coverart$/) {
            push(@$release_format_stats, ({'stat_name' => $stat_name, 'format' => $format}));
        }
        if (my ($type) = $stat_name =~ /^count\.coverart.type\.(.*)$/) {
            push(@$type_stats, ({'stat_name' => $stat_name, 'type' => $type}));
        }
    }

    $c->stash(
        template => 'statistics/coverart.tt',
        stats => $stats,
        release_type_stats => $release_type_stats,
        release_status_stats => $release_status_stats,
        release_format_stats => $release_format_stats,
        type_stats => $type_stats
    );
}

sub languages_scripts : Path('languages-scripts')
{
    my ($self, $c) = @_;

    my $stats = try_fetch_latest_statistics($c);

    my @language_stats;
    my $script_stats = [];
    my %language_column_stat = (
        releases => 'count.release.language',
        works => 'count.work.language'
    );
    my %languages = map { $_->iso_code_3 => $_ }
        grep { defined $_->iso_code_3 } $c->model('Language')->get_all();

    my $script_prefix = 'count.release.script';
    my %scripts = map { $_->iso_code => $_ } $c->model('Script')->get_all();

    for my $iso_code (keys %languages) {
        my %counts = map { $_ => $stats->statistic($language_column_stat{$_} . ".$iso_code") || 0 }
            keys %language_column_stat;
        my $total = sum values %counts;

        next unless $total > 0;

        push @language_stats, {
            entity => $languages{$iso_code},
            %counts,
            total => $total
        };
    }

    foreach my $stat_name
        (rev_nsort_by { $stats->statistic($_) } $stats->statistic_names) {
        if (my ($iso_code) = $stat_name =~ /^$script_prefix\.(.*)$/) {
            push(@$script_stats, ({'entity' => $scripts{$iso_code}, 'count' => $stats->statistic($stat_name)}));
        }
    }

    $c->stash(
        template => 'statistics/languages_scripts.tt',
        language_stats => [ rev_nsort_by { $_->{total} } @language_stats ],
        script_stats => $script_stats,
        date_collected => $stats->{date_collected}
    );
}

sub formats : Path('formats')
{
    my ($self, $c) = @_;

    my $stats = try_fetch_latest_statistics($c);

    my $format_stats = [];
    my $release_format_prefix = 'count.release.format';
    my $medium_format_prefix = 'count.medium.format';
    my %formats = map { $_->id => $_ } $c->model('MediumFormat')->get_all();

    foreach my $stat_name
        (rev_nsort_by { $stats->statistic($_) } $stats->statistic_names) {
        if (my ($format_id) = $stat_name =~ /^$medium_format_prefix\.(.*)$/) {
            my $release_stat = $stat_name;
            $release_stat =~ s/$medium_format_prefix/$release_format_prefix/;
            push(@$format_stats, ({'entity' => $formats{$format_id}, 'medium_count' => $stats->statistic($stat_name), 'medium_stat' => $stat_name, 'release_count' => $stats->statistic($release_stat), 'release_stat' => $release_stat}));
        }
    }

    $c->stash(
        template => 'statistics/formats.tt',
        format_stats => $format_stats,
        stats => $stats
    );
}

sub editors : Path('editors') {
    my ($self, $c) = @_;

    my $stats = try_fetch_latest_statistics($c);

    my $top_recently_active_editors =
        _editor_data_points($stats, 'editor.top_recently_active.rank',
                            'count.edit.top_recently_active.rank');
    my $top_active_editors =
        _editor_data_points($stats, 'editor.top_active.rank',
                            'count.edit.top_active.rank');
    my $top_recently_active_voters =
        _editor_data_points($stats, 'editor.top_recently_active_voters.rank',
                            'count.vote.top_recently_active_voters.rank');
    my $top_active_voters =
        _editor_data_points($stats, 'editor.top_active_voters.rank',
                            'count.vote.top_active_voters.rank');

    my @data_points = ( @$top_recently_active_editors, @$top_active_editors,
                        @$top_recently_active_voters, @$top_active_voters );

    my $editors = $c->model('Editor')->get_by_ids(map { $_->{editor_id} } @data_points);
    for my $data_point (@data_points) {
        $data_point->{editor} = $editors->{ delete $data_point->{editor_id} };
    }

    $c->stash(
        stats => $stats,
        top_recently_active_editors => $top_recently_active_editors,
        top_editors => $top_active_editors,

        top_recently_active_voters => $top_recently_active_voters,
        top_voters => $top_active_voters,
    );
}

sub _editor_data_point {
    my ($stats, $editor_id_key, $count_key, $index) = @_;

    my $editor_id = $stats->statistic("$editor_id_key.$index") or return undef;
    my $count = $stats->statistic("$count_key.$index") or return undef;

    return {
        editor_id => $editor_id,
        count => $count
    }
}

sub _editor_data_points {
    my ($stats, $editor_id, $count) = @_;
    return [
        grep { defined }
            map { _editor_data_point($stats, $editor_id, $count, $_) }
                (1..25)
    ];
}

sub relationships : Path('relationships') {
    my ($self, $c) = @_;
    my $stats = try_fetch_latest_statistics($c);
    my $pairs = [ $c->model('Relationship')->all_pairs() ];
    my $types = { map { (join '_', 'l', @$_) => { entity_types => \@$_, tree => $c->model('LinkType')->get_tree($_->[0], $_->[1]) } } @$pairs };
    $c->stash(
        types => $types,
	stats => $stats
    );
}

sub edits : Path('edits') {
    my ($self, $c) = @_;

    my $stats = try_fetch_latest_statistics($c);

    my %by_category;
    for my $class (EditRegistry->get_all_classes) {
        $by_category{$class->edit_category} ||= [];
        push @{ $by_category{$class->edit_category} }, $class;
    }

    for my $category (keys %by_category) {
        $by_category{$category} = [
            reverse sort {
                ($stats->statistic('count.edit.type.' . $a->edit_type) // 0) <=>
                    ($stats->statistic('count.edit.type.' . $b->edit_type) // 0)
                } @{ $by_category{$category} }
            ];
    }

    $c->stash(
        by_category => \%by_category,
        stats => $stats
    );
}

sub try_fetch_latest_statistics {
    my $c = shift;
    my $stats = $c->model('Statistics::ByDate')->get_latest_statistics()
        or $c->detach('no_statistics');

    return $stats;
}

sub no_statistics : Private {
    my ($self, $c) = @_;
    $c->stash( template => 'statistics/no_statistics.tt' );
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
