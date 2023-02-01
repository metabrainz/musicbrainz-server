package MusicBrainz::Server::Edit::Generic::Create;
use utf8;
use Moose;

use Clone qw( clone );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Role::Insert';

# Sub-classes are required to implement `_create_model`.
#
# N.B. This is not checked at compile-time.

sub _create_model { die 'Unimplemented' }

sub edit_kind { 'add' }

sub alter_edit_pending
{
    my $self = shift;
    my $model = $self->c->model( $self->_create_model);
    if ($model->does('MusicBrainz::Server::Data::Role::Editable')) {
        return {
            $self->_create_model => [ $self->entity_id ]
        }
    } else {
        return { }
    }
}

sub _build_related_entities
{
    my $self = shift;
    my $model = $self->c->model( $self->_create_model);
    if ($model->does('MusicBrainz::Server::Data::Role::LinksToEdit')) {
        return {
            $model->edit_link_table => [ $self->entity_id ]
        }
    } else {
        return { }
    }
}

sub insert
{
    my $self = shift;

    # Make a copy of the data so we don't accidently modify it
    my $hash   = $self->_insert_hash(clone($self->data));
    my $entity = $self->c->model( $self->_create_model )->insert( $hash );

    $self->entity_id($entity->{id});
    $self->entity_gid($entity->{gid}) if exists $entity->{gid};
}

sub reject {
    my $self = shift;
    my $model = $self->c->model($self->_create_model);

    MusicBrainz::Server::Edit::Exceptions::MustApply->throw(
        'This edit can’t be rejected because the entity is being used.',
    ) unless $model->can_delete($self->entity_id);

    $model->delete($self->entity_id);
}

sub _insert_hash
{
    my ($self, $data) = @_;
    return $data;
}

sub _is_disambiguation_needed {
    my ($self, %opts) = @_;

    my $table = $self->c->model($self->_create_model)->_table;
    return $self->c->sql->select_single_value(
        "SELECT 1 FROM $table
         WHERE lower(musicbrainz_unaccent(name)) = lower(musicbrainz_unaccent(?))
         LIMIT 1",
        $opts{name}
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
