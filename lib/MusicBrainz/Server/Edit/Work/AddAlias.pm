package MusicBrainz::Server::Edit::Work::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_WORK_ADD_ALIAS );
use MusicBrainz::Server::Translation qw ( N_l );

use aliased 'MusicBrainz::Server::Entity::Work';

extends 'MusicBrainz::Server::Edit::Alias::Add';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities';
with 'MusicBrainz::Server::Edit::Work';

sub _alias_model { shift->c->model('Work')->alias }

sub edit_name { N_l('Add work alias') }
sub edit_kind { 'add' }
sub edit_type { $EDIT_WORK_ADD_ALIAS }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Work')->adjust_edit_pending($adjust, $self->work_id);
    $self->c->model('Work')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

has 'work_id' => (
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
    $keys->{Work}->{ $self->work_id } = [];

    return $keys;
};

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data =  $self->$orig($loaded);
    $data->{work} = $loaded->{Work}->{ $self->work_id }
        || Work->new( name => $self->data->{entity}{name} );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

