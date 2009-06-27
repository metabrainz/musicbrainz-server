package MusicBrainz::Server::Edit::ReleaseGroup::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_DELETE );
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Entity::Types;
use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_RELEASEGROUP_DELETE }
sub edit_name { "Delete Release Group" }
sub entity_model { 'ReleaseGroup' }
sub entity_id { shift->release_group_id }

sub entities
{
    my $self = shift;
    return {
        release_group => [ $self->release_group_id ]
    }
}

has '+data' => (
    isa => Dict[
        release_group => Int
    ]
);

has 'release_group' => (
    isa => 'ReleaseGroup',
    is => 'rw'
);

sub release_group_id
{
    return shift->data->{release_group};
}

sub initialize
{
    my ($self, %args) = @_;
    $self->data({ release_group => $args{release_group_id} });
}

override 'accept' => sub
{
    my $self = shift;
    my $rg_data = MusicBrainz::Server::Data::ReleaseGroup->new(c => $self->c);
    $rg_data->delete($self->release_group_id);
};

__PACKAGE__->register_type;
__PACKAGE__->meta->make_immutable;

no Moose;
1;

