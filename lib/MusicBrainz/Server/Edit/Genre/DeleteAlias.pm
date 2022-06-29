package MusicBrainz::Server::Edit::Genre::DeleteAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_GENRE_DELETE_ALIAS );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Alias::Delete';
with 'MusicBrainz::Server::Edit::Genre';

use aliased 'MusicBrainz::Server::Entity::Genre';

sub _alias_model { shift->c->model('Genre')->alias }

sub edit_name { N_l('Remove genre alias') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_GENRE_DELETE_ALIAS }

sub _build_related_entities { { genre => [ shift->genre_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Genre')->adjust_edit_pending($adjust, $self->genre_id);
    $self->c->model('Genre')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub models {
    my $self = shift;
    return [ $self->c->model('Genre'), $self->c->model('Genre')->alias ];
}

has 'genre_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

has 'genre' => (
    isa => 'Genre',
    is => 'rw'
);

sub foreign_keys
{
    my $self = shift;
    return {
        Genre => [ $self->genre_id ],
    };
}

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig($loaded);
    $data->{genre} = to_json_object(
        $loaded->{Genre}{ $self->genre_id } ||
        Genre->new(name => $self->data->{entity}{name})
    );

    return $data;
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;
