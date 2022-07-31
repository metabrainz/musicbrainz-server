package MusicBrainz::Server::Edit::Mood::DeleteAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_MOOD_DELETE_ALIAS );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Alias::Delete';
with 'MusicBrainz::Server::Edit::Mood';

use aliased 'MusicBrainz::Server::Entity::Mood';

sub _alias_model { shift->c->model('Mood')->alias }

sub edit_name { N_l('Remove mood alias') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_MOOD_DELETE_ALIAS }

sub _build_related_entities { { mood => [ shift->mood_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Mood')->adjust_edit_pending($adjust, $self->mood_id);
    $self->c->model('Mood')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub models {
    my $self = shift;
    return [ $self->c->model('Mood'), $self->c->model('Mood')->alias ];
}

has 'mood_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

has 'mood' => (
    isa => 'Mood',
    is => 'rw'
);

sub foreign_keys
{
    my $self = shift;
    return {
        Mood => [ $self->mood_id ],
    };
}

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig($loaded);
    $data->{mood} = to_json_object(
        $loaded->{Mood}{ $self->mood_id } ||
        Mood->new(name => $self->data->{entity}{name})
    );

    return $data;
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;
