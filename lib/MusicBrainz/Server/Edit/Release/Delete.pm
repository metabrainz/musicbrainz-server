package MusicBrainz::Server::Edit::Release::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_DELETE );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::Generic::Delete';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities',
     'MusicBrainz::Server::Edit::Release';

sub edit_type { $EDIT_RELEASE_DELETE }
sub edit_name { N_lp('Remove release', 'edit type') }
sub _delete_model { 'Release' }
sub release_id { shift->entity_id }

around _build_related_entities => sub {
    my ($orig, $self) = splice(@_, 0, 2);
    my $related = $self->$orig(@_);

    my $release = $self->c->model('Release')->get_by_id(
        $self->data->{entity_id},
    );
    $self->c->model('Release')->load_related_info($release);

    for my $medium (@{ $release->{mediums} }) {
        $self->c->model('Track')->load_for_mediums($medium);
        my @tracks = $medium->all_tracks;
        $self->c->model('ArtistCredit')->load(@tracks);

        push @{ $related->{artist} }, map {
            map { $_->{artist}{id} } @{ $_->{artist_credit}->{names} }
        } @tracks;

        push @{ $related->{recording} },
            map { $_->{recording_id} } @tracks;
    }

    return $related;
};

override 'foreign_keys' => sub {
    my $self = shift;
    my $data = super();

    $data->{Release} = {
        $self->release_id => [ 'ArtistCredit' ],
    };
    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

