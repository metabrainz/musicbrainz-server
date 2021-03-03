package MusicBrainz::Server::Edit::Series::DeleteAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_SERIES_DELETE_ALIAS );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit::Alias::Delete';
with 'MusicBrainz::Server::Edit::Series';

use aliased 'MusicBrainz::Server::Entity::Series';

sub _alias_model { shift->c->model('Series')->alias }

sub edit_name { N_l('Remove series alias') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_SERIES_DELETE_ALIAS }

sub _build_related_entities { { series => [ shift->series_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Series')->adjust_edit_pending($adjust, $self->series_id);
    $self->c->model('Series')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

sub models {
    my $self = shift;
    return [ $self->c->model('Series'), $self->c->model('Series')->alias ];
}

has 'series_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

has 'series' => (
    isa => 'Series',
    is => 'rw'
);

sub foreign_keys
{
    my $self = shift;
    return {
        Series => [ $self->series_id ],
    };
}

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig($loaded);
    $data->{series} = to_json_object(
        $loaded->{Series}->{ $self->series_id } ||
        Series->new(name => $self->data->{entity}{name})
    );

    return $data;
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;
