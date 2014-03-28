package MusicBrainz::Server::Edit::Artist::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_ADD_ALIAS );
use MusicBrainz::Server::Translation qw ( N_l );

use aliased 'MusicBrainz::Server::Entity::Artist';

extends 'MusicBrainz::Server::Edit::Alias::Add';
with 'MusicBrainz::Server::Edit::Artist';

sub _alias_model { shift->c->model('Artist')->alias }

sub edit_name { N_l('Add artist alias') }
sub edit_kind { 'add' }
sub edit_type { $EDIT_ARTIST_ADD_ALIAS }

sub _build_related_entities { { artist => [ shift->artist_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Artist')->adjust_edit_pending($adjust, $self->artist_id);
    $self->c->model('Artist')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

has 'artist_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

around 'foreign_keys' => sub
{
    my $orig = shift;
    my $self = shift;

    my $keys = $self->$orig();
    $keys->{Artist}->{ $self->artist_id } = [];

    return $keys;
};

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data =  $self->$orig($loaded);
    $data->{artist} = $loaded->{Artist}->{ $self->artist_id }
        || Artist->new( name => $self->data->{entity}{name} );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

