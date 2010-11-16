package MusicBrainz::Server::Edit::Historic::EditReleaseName;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Int Str );

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_EDIT_RELEASE_NAME );
use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub edit_name     { l('Edit release name') }
sub historic_type { 3 }
sub edit_type     { $EDIT_HISTORIC_EDIT_RELEASE_NAME }

sub related_entities
{
    my $self = shift;
    return {
        release => $self->data->{release_ids}
    }
}

has '+data' => (
    isa => Dict[
        release_ids => ArrayRef[Int],
        old         => Dict[name => Str],
        new         => Dict[name => Str]
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
        name => {
            new => $self->data->{new}{name},
            old => $self->data->{old}{name},
        }
    }
}

sub upgrade
{
    my $self = shift;
    $self->data({
        release_ids => $self->album_release_ids($self->row_id),
        old      => {
            name => $self->previous_value,
        },
        new      => {
            name => $self->new_value
        }
    });

    return $self;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
