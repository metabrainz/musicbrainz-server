package MusicBrainz::Server::Edit::Label::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_DELETE );
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Entity::Types;
use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_LABEL_DELETE }
sub edit_name { "Delete Label" }

sub alter_edit_pending { { Label => [ shift->label_id ] } }
sub related_entities { { label => [ shift->label_id ] } }
sub models { [qw( Label )] }

has '+data' => (
    isa => Dict[
        label_id => Int
    ]
);

has 'label' => (
    isa => 'Label',
    is => 'rw'
);

has 'label_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{label_id} }
);

override 'accept' => sub
{
    my $self = shift;
    $self->c->model('Label')->delete($self->label_id);
};

__PACKAGE__->register_type;
__PACKAGE__->meta->make_immutable;

no Moose;
1;

