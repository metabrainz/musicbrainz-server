package MusicBrainz::Server::Edit::Recording::DeleteAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_DELETE_ALIAS );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Alias::Delete';
with 'MusicBrainz::Server::Edit::Recording';

use aliased 'MusicBrainz::Server::Entity::Recording';

sub _alias_model { shift->c->model('Recording')->alias }

sub edit_name { N_l('Remove recording alias') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_RECORDING_DELETE_ALIAS }

sub _build_related_entities { { recording => [ shift->recording_id ] } }

sub adjust_edit_pending {
    my ($self, $adjust) = @_;

    $self->c->model('Recording')->adjust_edit_pending($adjust, $self->recording_id);
    $self->c->model('Recording')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

has 'recording_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

sub foreign_keys {
    my $self = shift;
    return {
        Recording => [ $self->recording_id ],
    };
}

around 'build_display_data' => sub {
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig($loaded);
    $data->{recording} = to_json_object(
        $loaded->{Recording}{ $self->recording_id } ||
        Recording->new(name => $self->data->{entity}{name})
    );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
