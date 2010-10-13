package MusicBrainz::Server::Edit::Medium::Delete;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_DELETE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Medium::RelatedEntities';

sub edit_type { $EDIT_MEDIUM_DELETE }
sub edit_name { 'Remove medium' }
sub medium_id { shift->data->{medium_id} }

sub alter_edit_pending { { Medium => [ shift->medium_id ] } }

has '+data' => (
    isa => Dict[
        medium_id => Int,
        format_id => Nullable[Int],
        tracklist_id => Int,
        name => Nullable[Str],
        position => Int,
        release_id => Int
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        MediumFormat => { $self->data->{format_id} => [] },
        Release => { $self->data->{release_id} => [qw( ArtistCredit )] }
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        format => $loaded->{MediumFormat}->{ $self->data->{format_id} },
        release => $loaded->{Release}->{ $self->data->{release_id} },
        map { $_ => $self->data->{$_} } qw( name position tracklist_id )
    }
}

sub initialize
{
    my ($self, %args) = @_;

    my $medium = $args{medium} or die 'Missing required medium object';
    $self->data({
        medium_id => $medium->id,
        format_id => $medium->format_id,
        tracklist_id => $medium->tracklist_id,
        name => $medium->name,
        position => $medium->position,
        release_id => $medium->release_id,
    });
}

sub accept
{
    my $self = shift;
    $self->c->model('Medium')->delete($self->medium_id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
