package MusicBrainz::Server::Edit::Release::DeleteAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_DELETE_ALIAS );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Alias::Delete';
with 'MusicBrainz::Server::Edit::Release';

use aliased 'MusicBrainz::Server::Entity::Release';

sub _alias_model { shift->c->model('Release')->alias }

sub edit_name { N_l('Remove release alias') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_RELEASE_DELETE_ALIAS }

sub _build_related_entities { { release => [ shift->release_id ] } }

sub adjust_edit_pending {
    my ($self, $adjust) = @_;

    $self->c->model('Release')->adjust_edit_pending($adjust, $self->release_id);
    $self->c->model('Release')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

has 'release_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

sub foreign_keys {
    my $self = shift;
    return {
        Release => [ $self->release_id ],
    };
}

around 'build_display_data' => sub {
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig($loaded);
    $data->{release} = to_json_object(
        $loaded->{Release}{ $self->release_id } ||
        Release->new(name => $self->data->{entity}{name})
    );

    return $data;
};

sub release_ids {}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
