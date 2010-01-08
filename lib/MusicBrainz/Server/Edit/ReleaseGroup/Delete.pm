package MusicBrainz::Server::Edit::ReleaseGroup::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_DELETE );
use MusicBrainz::Server::Data::Label;
use MusicBrainz::Server::Entity::Types;
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_RELEASEGROUP_DELETE }
sub edit_name { "Delete Release Group" }

sub related_entities { { release_group => [ shift->release_group_id ] } }
sub alter_edit_pending { { ReleaseGroup => [ shift->release_group_id ] } }

has '+data' => (
    isa => Dict[
        release_group => Int,
        name => Str,
    ]
);

sub release_group_id { shift->data->{release_group} }

sub build_display_data
{
    return {
        name => shift->data->{name}
    }
}

sub initialize
{
    my ($self, %args) = @_;
    my $release_group = delete $args{release_group} or die "Required 'release_group' object";

    $self->data({
        name          => $release_group->name,
        release_group => $release_group->id,
    });
}

override 'accept' => sub
{
    my $self = shift;
    my $rg_data = MusicBrainz::Server::Data::ReleaseGroup->new(c => $self->c);
    MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw
          unless $rg_data->can_delete($self->release_group_id);
    $rg_data->delete($self->release_group_id);
};

__PACKAGE__->meta->make_immutable;

no Moose;
1;

