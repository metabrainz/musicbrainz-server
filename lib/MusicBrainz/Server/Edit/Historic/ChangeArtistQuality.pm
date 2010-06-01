package MusicBrainz::Server::Edit::Historic::ChangeArtistQuality;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Int Str );

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_CHANGE_ARTIST_QUALITY );

extends 'MusicBrainz::Server::Edit::Historic';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub edit_name     { 'Change artist quality' }
sub historic_type { 52 }
sub edit_type     { $EDIT_HISTORIC_CHANGE_ARTIST_QUALITY }

sub related_entities
{
    my $self = shift;
    return {
        artist => [ $self->data->{artist_id} ]
    }
}

has '+data' => (
    isa => Dict[
        artist_id => Int,
        new => Dict[quality => Int],
        old => Dict[quality => Int],
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Artist => [ $self->data->{artist_id} ],
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        artist => $loaded->{Artist}{ $self->data->{artist_id} },
        quality => {
            old => $self->data->{old}{quality},
            new => $self->data->{new}{quality}
        }
    }
}

sub upgrade
{
    my $self = shift;
    $self->data({
        artist_id => $self->artist_id,
        old       => { quality => $self->previous_value },
        new       => { quality => $self->new_value },
    });

    return $self;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
