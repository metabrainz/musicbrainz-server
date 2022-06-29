package MusicBrainz::Server::Controller::Statistics;
use Digest::MD5 qw( md5_hex );
use Moose;
use MusicBrainz::Server::Data::Statistics::ByDate;
use MusicBrainz::Server::Data::Statistics::ByName;
use MusicBrainz::Server::Data::CountryArea;
use MusicBrainz::Server::Data::Area;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array to_json_object );
use MusicBrainz::Server::Form::Utils qw( build_type_info );
use List::AllUtils qw( rev_nsort_by sort_by sum );
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
    my @statuses = $c->model('ReleaseStatus')->get_all();
    my @packagings = $c->model('ReleasePackaging')->get_all();
    my @primary_types = $c->model('ReleaseGroupType')->get_all();
    my @secondary_types = $c->model('ReleaseGroupSecondaryType')->get_all();
    my @label_types = sort_by { $_->l_name } $c->model('LabelType')->get_all();
    my @work_types = sort_by { $_->l_name } $c->model('WorkType')->get_all();
    my @area_types = sort_by { $_->l_name } $c->model('AreaType')->get_all();
    my @place_types = sort_by { $_->l_name } $c->model('PlaceType')->get_all();
    my @series_types = sort_by { $_->l_name } $c->model('SeriesType')->get_all();
    my @instrument_types = sort_by { $_->l_name } $c->model('InstrumentType')->get_all();
    my @event_types = sort_by { $_->l_name } $c->model('EventType')->get_all();

    my @work_attribute_types = sort_by { $_->l_name }
        $c->model('WorkAttributeType')->get_all;

    my %props = (
        dateCollected => $latest_stats->{date_collected},
        statuses => to_json_array(\@statuses),
        packagings => to_json_array(\@packagings),
        primaryTypes => to_json_array(\@primary_types),
        secondaryTypes => to_json_array(\@secondary_types),
        labelTypes => to_json_array(\@label_types),
        workTypes => to_json_array(\@work_types),
        areaTypes => to_json_array(\@area_types),
        placeTypes => to_json_array(\@place_types),
        seriesTypes => to_json_array(\@series_types),
        instrumentTypes => to_json_array(\@instrument_types),
        eventTypes => to_json_array(\@event_types),
        workAttributeTypes => to_json_array(\@work_attribute_types),
        stats => $latest_stats->{data},
    );

    $c->stash(
        current_view    => 'Node',
        component_path  => 'statistics/Index',
        component_props => \%props,
    );
}

sub timeline_type_data : Path('timeline/type-data') {
    my ($self, $c) = @_;

    my %area_types = map { $_->id => $_ } $c->model('AreaType')->get_all;
    my @countries = $c->model('CountryArea')->get_all;
    my %countries = map { $_->country_code => $_ } @countries;
    my %event_types = map { $_->id => $_ } $c->model('EventType')->get_all;
    my %instrument_types = map { $_->id => $_ } $c->model('InstrumentType')->get_all;
    my %label_types = map { $_->id => $_ } $c->model('LabelType')->get_all;
    my %languages = map { $_->iso_code_3 => $_ }
        grep { defined $_->iso_code_3 } $c->model('Language')->get_all;
    my %scripts = map { $_->iso_code => $_ } $c->model('Script')->get_all;
    my %formats = map { $_->id => $_ } $c->model('MediumFormat')->get_all;
    my %statuses = map { $_->id => $_ } $c->model('ReleaseStatus')->get_all;
    my %packagings = map { $_->id => $_ } $c->model('ReleasePackaging')->get_all;
    my %place_types = map { $_->id => $_ } $c->model('PlaceType')->get_all;
    my %release_group_types = map { $_->id => $_ } $c->model('ReleaseGroupType')->get_all;
    my %release_group_secondary_types = map { $_->id => $_ } $c->model('ReleaseGroupSecondaryType')->get_all;
    my @rel_pairs = $c->model('Relationship')->all_pairs;
    my %rel_types = $c->model('Relationship')->get_types_for_timeline;
    my %series_types = map { $_->id => $_ } $c->model('SeriesType')->get_all;
    my %work_attributes = map { $_->id => $_ } $c->model('WorkAttributeType')->get_all;
    my %work_types = map { $_->id => $_ } $c->model('WorkType')->get_all;
    my %edit_types;
    for my $class (EditRegistry->get_all_classes) {
        $edit_types{$class->edit_type} = { name => $class->edit_name };
    }

    my $body = $c->json_canonical_utf8->encode({
        areaTypes => \%area_types,
        countries => \%countries,
        editTypes => \%edit_types,
        eventTypes => \%event_types,
        formats => \%formats,
        instrumentTypes => \%instrument_types,
        labelTypes => \%label_types,
        languages => \%languages,
        packagings => \%packagings,
        placeTypes => \%place_types,
        relationshipTables => \@rel_pairs,
        relationshipTypes => \%rel_types,
        releaseGroupTypes => \%release_group_types,
        releaseGroupSecondaryTypes => \%release_group_secondary_types,
        scripts => \%scripts,
        seriesTypes => \%series_types,
        statuses => \%statuses,
        workAttributes => \%work_attributes,
        workTypes => \%work_types,
    });
    $c->res->body($body);
    $c->res->content_type('application/json; charset=utf-8');
    $c->res->headers->etag(md5_hex($body));
}

sub timeline : Path('timeline/main')
{
    my ($self, $c) = @_;

    $c->stash(template => 'statistics/timeline.tt');
}

sub timeline_redirect : Path('timeline')
{
    my ($self, $c) = @_;
    $c->response->redirect($c->uri_for('/statistics/timeline/main'), 303);
}

sub individual_timeline : Path('timeline') Args(1)
{
    my ($self, $c, $stat) = @_;

    $c->stash(
        template => 'statistics/timeline.tt',
        show_all => 1,
    );
}

sub dataset : Local Args(1)
{
    my ($self, $c, $dataset) = @_;

    $c->res->content_type('application/json; charset=utf-8');
    my $tomorrow = Date_to_Time(Add_Delta_Days(Today(1), 1), 0, 0, 0);
    $c->res->headers->expires($tomorrow);

    my $statistic = $c->model('Statistics::ByName')->get_statistic($dataset);
    $c->res->body($c->json_utf8->encode($statistic));
}

sub countries : Local
{
    my ($self, $c) = @_;

    my $stats = try_fetch_latest_statistics($c);
    my $country_stats = [];
    my $artist_country_prefix = 'count.artist.country';
    my $release_country_prefix = 'count.release.country';
    my $label_country_prefix = 'count.label.country';
    my @countries = $c->model('CountryArea')->get_all();
    my %countries = map { $_->country_code => $_ } grep { defined $_->country_code } @countries;
    foreach my $stat_name
        (rev_nsort_by { $stats->statistic($_) } $stats->statistic_names) {
        if (my ($iso_code) = $stat_name =~ /^$artist_country_prefix\.(.*)$/) {
            my $release_stat = $stat_name =~ s/$artist_country_prefix/$release_country_prefix/r;
            my $label_stat = $stat_name =~ s/$artist_country_prefix/$label_country_prefix/r;
            push(@$country_stats, ({
                'entity' => to_json_object($countries{$iso_code}),
                'artist_count' => $stats->statistic($stat_name),
                'release_count' => $stats->statistic($release_stat),
                'label_count' => $stats->statistic($label_stat)
            }));
        }
    }

    my %props = (
        dateCollected => $stats->{date_collected},
        countryStats => $country_stats,
    );

    $c->stash(
        current_view => 'Node',
        component_path => 'statistics/Countries',
        component_props => \%props,
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

    my %props = (
        dateCollected => $stats->{date_collected},
        releaseFormatStats => $release_format_stats,
        releaseStatusStats => $release_status_stats,
        releaseTypeStats => $release_type_stats,
        stats => $stats->{data},
        typeStats => $type_stats,
    );

    $c->stash(
        current_view => 'Node',
        component_path => 'statistics/CoverArt',
        component_props => \%props,
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

    # Since we look at the language (not the stat) list later, we need this
    $languages{'null'} = undef;

    my $script_prefix = 'count.release.script';
    my %scripts = map { $_->iso_code => $_ } $c->model('Script')->get_all();

    for my $iso_code (keys %languages) {
        my %counts = map { $_ => $stats->statistic($language_column_stat{$_} . ".$iso_code") || 0 }
            keys %language_column_stat;
        my $total = sum values %counts;

        next unless $total > 0;

        push @language_stats, {
            entity => to_json_object($languages{$iso_code}),
            %counts,
            total => $total
        };
    }

    foreach my $stat_name
        (rev_nsort_by { $stats->statistic($_) } $stats->statistic_names) {
        if (my ($iso_code) = $stat_name =~ /^$script_prefix\.(.*)$/) {
            push(@$script_stats, ({'entity' => to_json_object($scripts{$iso_code}), 'count' => $stats->statistic($stat_name)}));
        }
    }

    my %props = (
        dateCollected => $stats->{date_collected},
        languageStats => [ rev_nsort_by { $_->{total} } @language_stats ],
        scriptStats => $script_stats,
    );

    $c->stash(
        current_view => 'Node',
        component_path => 'statistics/LanguagesScripts',
        component_props => \%props,
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
            my $release_stat = $stat_name =~ s/$medium_format_prefix/$release_format_prefix/r;
            push(@$format_stats, ({'entity' => to_json_object($formats{$format_id}), 'medium_count' => $stats->statistic($stat_name), 'medium_stat' => $stat_name, 'release_count' => $stats->statistic($release_stat), 'release_stat' => $release_stat}));
        }
    }

    my %props = (
        dateCollected => $stats->{date_collected},
        formatStats => $format_stats,
        stats => $stats->{data},
    );

    $c->stash(
        current_view => 'Node',
        component_path => 'statistics/Formats',
        component_props => \%props,
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
        $data_point->{editor} = to_json_object($editors->{ delete $data_point->{editor_id} });
    }

    my %props = (
        dateCollected => $stats->{date_collected},
        topRecentlyActiveEditors => $top_recently_active_editors,
        topEditors => $top_active_editors,
        topRecentlyActiveVoters => $top_recently_active_voters,
        topVoters => $top_active_voters,
    );

    $c->stash(
        current_view => 'Node',
        component_path => 'statistics/Editors',
        component_props => \%props,
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
    my $types = { map { (join '_', 'l', @$_) => { entity_types => \@$_, tree => build_type_info($c, qr/.*/, $c->model('LinkType')->get_tree($_->[0], $_->[1])) } } @$pairs };

    my %props = (
        dateCollected => $stats->{date_collected},
        stats => $stats->{data},
        types => $types,
    );

    $c->stash(
        current_view => 'Node',
        component_path => 'statistics/Relationships',
        component_props => \%props,
    );
}

sub edits : Path('edits') {
    my ($self, $c) = @_;

    my $stats = try_fetch_latest_statistics($c);

    my %by_category;
    for my $class (EditRegistry->get_all_classes) {
        $by_category{$class->edit_category} ||= [];
        push @{ $by_category{$class->edit_category} }, {edit_type => $class->edit_type, edit_name => $class->edit_name};
    }

    for my $category (keys %by_category) {
        $by_category{$category} = [
            reverse sort {
                ($stats->statistic('count.edit.type.' . $a->{edit_type}) // 0) <=>
                    ($stats->statistic('count.edit.type.' . $b->{edit_type}) // 0)
                } @{ $by_category{$category} }
            ];
    }

    my %props = (
        dateCollected => $stats->{date_collected},
        stats => $stats->{data},
        statsByCategory => \%by_category,
    );

    $c->stash(
        current_view => 'Node',
        component_path => 'statistics/Edits',
        component_props => \%props,
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
    $c->stash(
        current_view => 'Node',
        component_path => 'statistics/NoStatistics',
    );
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation Inc.

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

1;
