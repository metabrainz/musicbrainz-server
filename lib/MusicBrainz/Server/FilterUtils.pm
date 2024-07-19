package MusicBrainz::Server::FilterUtils;
use strict;
use warnings;

use base 'Exporter';

our @EXPORT_OK = qw(
    create_artist_events_form
    create_artist_release_groups_form
    create_artist_releases_form
    create_artist_recordings_form
    create_artist_works_form
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
    my ($c, $artist_id) = @_;

    my %form_args = (
        entity_type => 'release_group',
        secondary_types => [ $c->model('ReleaseGroupSecondaryType')->get_all ],
        types => [ $c->model('ReleaseGroupType')->get_all ],
    );

    $form_args{artist_credits} =
        $c->model('ReleaseGroup')->find_artist_credits_by_artist($artist_id);

    return $c->form(filter_form => 'Filter::ReleaseGroup', %form_args);
}

sub create_artist_releases_form {
    my ($c, $artist_id) = @_;

    my %form_args = (entity_type => 'release');

    $form_args{artist_credits} =
        $c->model('Release')->find_artist_credits_by_artist($artist_id);
    $form_args{countries} = [$c->model('CountryArea')->get_all];
    $form_args{labels} =
        $c->model('Release')->find_labels_by_artist($artist_id);
    $form_args{statuses} = [$c->model('ReleaseStatus')->get_all];

    return $c->form(filter_form => 'Filter::Release', %form_args);
}

sub create_artist_recordings_form {
    my ($c, $artist_id) = @_;

    my %form_args = (entity_type => 'recording');

    $form_args{artist_credits} =
        $c->model('Recording')->find_artist_credits_by_artist($artist_id);

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

1;

