package MusicBrainz::Server::Edit::Role::Insert;
use Moose::Role;
use namespace::autoclean;

has 'entity_id' => (
    isa => 'Int',
    is  => 'rw'
);

has 'entity_gid' => (
    isa => 'Str',
    is  => 'rw'
);

override 'to_hash' => sub
{
    my $self = shift;
    my $hash = super(@_);
    die 'Role::Insert used without setting entity_id!'
        unless $self->entity_id;
    $hash->{entity_id} = $self->entity_id;
    $hash->{entity_gid} = $self->entity_gid if $self->entity_gid;
    return $hash;
};

before 'restore' => sub
{
    my ($self, $hash) = @_;
    # Sadly, we now have some edits (AddReleaseEdits) that didn't have an entity_id set
    # There are also a few edits where entity_id is 0; delete always
    my $entity_id = delete $hash->{entity_id};
    $self->entity_id($entity_id)
        if $entity_id;
    $self->entity_gid(delete $hash->{entity_gid})
        if $hash->{entity_gid};
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
