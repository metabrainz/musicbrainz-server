package MusicBrainz::Server::Edit::ReleaseGroup::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_MERGE );
use MusicBrainz::Server::Data::ReleaseGroup;
use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

sub edit_name { "Merge Release Groups" }
sub edit_type { $EDIT_RELEASEGROUP_MERGE }
sub entity_model { 'ReleaseGroup' }

sub entity_id
{
    my $self = shift;
    return [ $self->old_release_group_id, $self->new_release_group_id ]
}

sub old_release_group_id { shift->data->{old_group} }
sub new_release_group_id { shift->data->{new_group} }

sub entities
{
    my $self = shift;
    return {
        release_group => [
            $self->old_release_group_id,
            $self->new_release_group_id
        ]
    }
}

has [qw( old_release_group new_release_group )] => (
    isa => 'ReleaseGroup',
    is => 'rw',
);

has '+data' => (
    isa => Dict[
        old_group => Int,
        new_group => Int,
    ]
);

sub initialize
{
    my ($self, %args) = @_;
    $self->data({
        old_group => $args{old_release_group_id},
        new_group => $args{new_release_group_id}
    });
}

override 'accept' => sub
{
    my ($self) = @_;
    $self->c->model('ReleaseGroup')->merge($self->new_release_group_id, $self->old_release_group_id);
};

__PACKAGE__->register_type;
__PACKAGE__->meta->make_immutable;

no Moose;
1;
