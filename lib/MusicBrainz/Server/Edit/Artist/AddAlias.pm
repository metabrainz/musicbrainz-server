package MusicBrainz::Server::Edit::Artist::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_ADD_ALIAS );

extends 'MusicBrainz::Server::Edit::Alias::Add';

sub _alias_model { shift->c->model('Artist')->alias }

sub edit_name { 'Add artist alias' }
sub edit_type { $EDIT_ARTIST_ADD_ALIAS }

sub related_entities { { artist => [ shift->artist_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Artist')->adjust_edit_pending($adjust, $self->artist_id);
    $self->c->model('Artist')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub models {
    my $self = shift;
    return [ $self->c->model('Artist'), $self->c->model('Artist')->alias ];
}

has 'artist_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity_id} }
);

has 'artist' => (
    isa => 'Artist',
    is => 'rw'
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

