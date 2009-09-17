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

sub related_entities { { release_group => [ shift->release_group_id ] } }
sub alter_edit_pending { { ReleaseGroup => [ shift->release_group_id ] } }
sub models { [qw( ReleaseGroup )] }

has '+data' => (
    isa => Dict[
        release_group => Int
    ]
);

has 'release_group_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{release_group} }
);

has 'release_group' => (
    isa => 'ReleaseGroup',
    is => 'rw'
);

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

__PACKAGE__->meta->make_immutable;

no Moose;
1;

