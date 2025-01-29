package MusicBrainz::Server::FilterUtils;
use strict;
use warnings;

use base 'Exporter';
use List::AllUtils qw( any );

our @EXPORT_OK = qw(
    create_artist_events_form
    create_artist_release_groups_form
    create_artist_releases_form
    create_artist_recordings_form
    create_artist_works_form
    create_label_releases_form
);

sub create_artist_events_form {
    my ($c, $artist_id) = @_;

    my %form_args = (
        entity_type => 'event',
        types => [ $c->model('EventType')->get_all ],
    );

    return $c->form(filter_form => 'Filter::Event', %form_args);
}

sub create_artist_release_groups_form {
    my ($c, $artist_id, $want_all_statuses, $want_va_only) = @_;

    my %form_args = (
        entity_type => 'release_group',
        secondary_types => [ $c->model('ReleaseGroupSecondaryType')->get_all ],
        types => [ $c->model('ReleaseGroupType')->get_all ],
    );

    $form_args{artist_credits} =
        $c->model('ReleaseGroup')->find_artist_credits_by_artist($artist_id, $want_all_statuses, $want_va_only);
    preserve_selected_artist_credit($c, $form_args{artist_credits});

    return $c->form(filter_form => 'Filter::ReleaseGroup', %form_args);
}

sub create_artist_releases_form {
    my ($c, $artist_id) = @_;

    my %form_args = (entity_type => 'release');

    $form_args{artist_credits} =
        $c->model('ArtistCredit')->find_by_release_artist($artist_id);
    preserve_selected_artist_credit($c, $form_args{artist_credits});
    $form_args{countries} = [$c->model('CountryArea')->get_all];
    $form_args{labels} =
        [$c->model('Label')->find_by_release_artist($artist_id)];
    $form_args{statuses} = [$c->model('ReleaseStatus')->get_all];

    return $c->form(filter_form => 'Filter::ReleaseForArtist', %form_args);
}

sub create_artist_recordings_form {
    my ($c, $artist_id) = @_;

    my %form_args = (entity_type => 'recording');

    $form_args{artist_credits} =
        $c->model('ArtistCredit')->find_by_recording_artist($artist_id);
    preserve_selected_artist_credit($c, $form_args{artist_credits});

    return $c->form(filter_form => 'Filter::Recording', %form_args);
}

sub create_artist_works_form {
    my ($c, $artist_id) = @_;

    my %form_args = (
        entity_type => 'work',
        languages => $c->model('Work')->find_languages_by_artist($artist_id),
        types => [ $c->model('WorkType')->get_all ],
    );

    return $c->form(filter_form => 'Filter::Work', %form_args);
}

sub create_label_releases_form {
    my ($c, $label_id) = @_;

    my %form_args = (entity_type => 'release');

    $form_args{artist_credits} =
        $c->model('ArtistCredit')->find_by_release_label($label_id);
    preserve_selected_artist_credit($c, $form_args{artist_credits});
    $form_args{countries} = [$c->model('CountryArea')->get_all];
    $form_args{labels} =
        [$c->model('Label')->find_by_release_label($label_id)];
    $form_args{statuses} = [$c->model('ReleaseStatus')->get_all];

    return $c->form(filter_form => 'Filter::ReleaseForLabel', %form_args);
}

sub preserve_selected_artist_credit {
    my ($c, $artist_credits) = @_;

    # In case a filter link is bookmarked but the selected artist credit is
    # later not among the available options, push it onto the option list
    # to preserve the intent of the filter (showing no results until the AC
    # is possibly used again).
    my $selected_artist_credit_id = $c->req->query_params->{'filter.artist_credit_id'};
    if ($selected_artist_credit_id) {
        unless (any { $_->id == $selected_artist_credit_id } @$artist_credits) {
            my $artist_credit = $c->model('ArtistCredit')->get_by_id($selected_artist_credit_id);
            if ($artist_credit) {
                unshift @$artist_credits, $artist_credit;
            }
        }
    }
}

1;

