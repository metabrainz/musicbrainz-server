package MusicBrainz::Server::Edit::Medium::SetTrackLengths;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_SET_TRACK_LENGTHS );

use aliased 'MusicBrainz::Server::Entity::Release';

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';

sub edit_name { 'Set track\ lengths' }
sub edit_type { $EDIT_SET_TRACK_LENGTHS }

has '+data' => (
    isa => Dict[
        tracklist_id => Int,
        cdtoc_id => Int,
        affected_releases => ArrayRef[Dict[
            id => Int,
            name => Str,
        ]]
    ]
);

sub foreign_keys {
    my $self = shift;
    return {
        Release => {
            map { $_ => [ 'ArtistCredit' ] } $self->_release_ids
        }
    }
}

sub build_display_data {
    my ($self, $loaded) = @_;
    return {
        releases => [
            map {
                $loaded->{Release}{ $_->{id} } ||
                    Release->new( name => $_->{name} )
            } @{ $self->data->{affected_releases} }
        ]
    }
}

sub initialize {
    my ($self, %opts) = @_;
    my $tracklist_id = $opts{tracklist_id}
        or die 'Missing tracklist ID';

    my $cdtoc_id = $opts{cdtoc_id}
        or die 'Missing CDTOC ID';

    my ($mediums) = $self->c->model('Medium')
        ->find_by_tracklist($tracklist_id, 100, 0);

    $self->c->model('Release')->load(@$mediums);
    $self->c->model('ArtistCredit')->load(map { $_->release } @$mediums);

    $self->data({
        tracklist_id => $tracklist_id,
        cdtoc_id => $cdtoc_id,
        affected_releases => [ map +{
            id => $_->id,
            name => $_->name
        }, @$releases ]
    })
}

sub accept {
    my $self = shift;
    $self->c->model('Tracklist')->set_lengths_to_cdtoc(
        $self->data->{tracklist_id},
        $self->data->{cdtoc_id}
    );
}

__PACKAGE__->meta->make_immutable;
1;
