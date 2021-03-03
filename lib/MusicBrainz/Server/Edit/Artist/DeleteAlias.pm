package MusicBrainz::Server::Edit::Artist::DeleteAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_DELETE_ALIAS );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Alias::Delete';
with 'MusicBrainz::Server::Edit::Artist';

use aliased 'MusicBrainz::Server::Entity::Artist';

sub _alias_model { shift->c->model('Artist')->alias }

sub edit_name { N_l('Remove artist alias') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_ARTIST_DELETE_ALIAS }

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

sub foreign_keys
{
    my $self = shift;
    return {
        Artist => [ $self->artist_id ],
    };
}

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig($loaded);
    $data->{artist} = to_json_object(
        $loaded->{Artist}->{ $self->artist_id } ||
        Artist->new(name => $self->data->{entity}{name})
    );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
