package MusicBrainz::Server::Edit::Work::DeleteAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_WORK_DELETE_ALIAS );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Alias::Delete';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities';
with 'MusicBrainz::Server::Edit::Work';

use aliased 'MusicBrainz::Server::Entity::Work';

sub _alias_model { shift->c->model('Work')->alias }

sub edit_name { N_l('Remove work alias') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_WORK_DELETE_ALIAS }

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

sub foreign_keys
{
    my $self = shift;
    return {
        Work => [ $self->work_id ],
    };
}

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig($loaded);
    $data->{work} = to_json_object(
        $loaded->{Work}{ $self->work_id } ||
        Work->new( name => $self->data->{entity}{name} )
    );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
