package MusicBrainz::Server::Edit::Historic::AddDiscID;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Int Str );

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_ADD_DISCID );
use MusicBrainz::Server::Entity::CDTOC;

extends 'MusicBrainz::Server::Edit::Historic';

sub edit_name     { 'Add disc ID' }
sub historic_type { 32 }
sub edit_type     { $EDIT_HISTORIC_ADD_DISCID }
sub edit_template { 'historic/add_disc_id' }

sub related_entities
{
    my $self = shift;
    return {
        release => $self->data->{release_ids}
    }
}

has '+data' => (
    isa => Dict[
        release_name => Str,
        release_ids  => ArrayRef[Int],
        full_toc     => Str,
        cdtoc_id     => Int
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Release => { map { $_ => [ 'ArtistCredit' ] } @{ $self->data->{release_ids} } }
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        releases => [ map { $loaded->{Release}->{$_} } @{ $self->data->{release_ids} } ],
        cdtoc => MusicBrainz::Server::Entity::CDTOC->new_from_toc(
            $self->data->{full_toc}
        )
    }
}

sub upgrade
{
    my $self = shift;
    $self->data({
        release_ids  => $self->album_release_ids($self->new_value->{AlbumId}),
        release_name => $self->new_value->{AlbumName},
        full_toc     => $self->new_value->{FullTOC},
        cdtoc_id     => $self->new_value->{CDTOCId},
    });

    return $self;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
