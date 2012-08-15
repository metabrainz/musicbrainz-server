package MusicBrainz::Server::Edit::Recording::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_MERGE );
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities' => {
    -excludes => 'recording_ids'
};
with 'MusicBrainz::Server::Edit::Recording';

sub edit_name { N_l('Merge recordings') }
sub edit_type { $EDIT_RECORDING_MERGE }
sub _merge_model { 'Recording' }

sub recording_ids { @{ shift->_entity_ids } }

sub foreign_keys
{
    my $self = shift;
    return {
        Recording => {
            $self->data->{new_entity}{id} => [ 'ArtistCredit' ],
            map {
                $_->{id} => [ 'ArtistCredit' ]
            } @{ $self->data->{old_entities} }
        }
    }
}

before build_display_data => sub {
    my ($self, $loaded) = @_;

    $self->c->model('ISRC')->load_for_recordings(
        grep { $_ && !$_->all_isrcs } map { $loaded->{Recording}{$_} } $self->recording_ids
    );
};

sub bulk_load {
    my ($class, $c, @edits) = @_;

    my %recording_releases_map = $c->model('Release')->find_by_recordings(map {
        $_->recording_ids
    } @edits);

    $result_map{$_}->extra(
        [ map { $_->[0] } @{ $recording_releases_map{$_} } ]
    ) for keys %recording_releases_map;

            my @releases = map { @{ $_->extra } } @$results;
            $c->model('ReleaseGroup')->load(@releases);
            $c->model('ReleaseGroupType')->load(map { $_->release_group } @releases);
            $c->model('Medium')->load_for_releases(@releases);
            $c->model('Tracklist')->load(map { $_->all_mediums } @releases);
            $c->model('Track')->load_for_tracklists(map { $_->tracklist }
                                                    map { $_->all_mediums } @releases);
            $c->model('Recording')->load(map { $_->tracklist->all_tracks }
                                         map { $_->all_mediums } @releases);
            $c->model('ISRC')->load_for_recordings(map { $_->entity } @$results);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

