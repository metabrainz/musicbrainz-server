package MusicBrainz::Server::FilterUtils;

use base 'Exporter';
use MusicBrainz::Server::Translation qw( l );

our @EXPORT_OK = qw(
    create_artist_release_groups_form
    create_artist_releases_form
    create_artist_recordings_form
);

sub create_artist_release_groups_form {
    my ($c, $artist_id) = @_;

    my %form_args = (
        types => [ $c->model('ReleaseGroupType')->get_all ],
    );

    $form_args{artist_credits} =
        $c->model('ReleaseGroup')->find_artist_credits_by_artist($artist_id);

    $c->stash(filter_submit_text => l('Filter release groups'));
    return $c->form(filter_form => 'Filter::ReleaseGroup', %form_args);
}

sub create_artist_releases_form {
    my ($c, $artist_id) = @_;

    my %form_args = ( );

    $form_args{artist_credits} =
        $c->model('Release')->find_artist_credits_by_artist($artist_id);

    $c->stash(filter_submit_text => l('Filter releases'));
    return $c->form(filter_form => 'Filter::Recording', %form_args);
}

sub create_artist_recordings_form {
    my ($c, $artist_id) = @_;

    my %form_args = ( );

    $form_args{artist_credits} =
        $c->model('Recording')->find_artist_credits_by_artist($artist_id);

    $c->stash(filter_submit_text => l('Filter recordings'));
    return $c->form(filter_form => 'Filter::Recording', %form_args);
}

1;

