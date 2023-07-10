package MusicBrainz::Server::Edit::Role::AllowAmending;
use MooseX::Role::Parameterized;
use namespace::autoclean;

parameter create_edit_type => ( isa => 'Int', required => 1);
parameter entity_type => ( isa => 'Str', required => 1);

role {
    my $params = shift;

    my $create_edit_type = $params->create_edit_type;
    my $entity_type = $params->entity_type;

    requires 'c', 'editor_id';

=method can_amend

Check if an editor is still allowed to amend an entity, that is,
if it has been created by the same editor less than one day ago.

=cut

    method 'can_amend' => sub {
        my ($self, $amended_entity_id) = @_;

        my $add_entity_edit = $self->c->sql->select_single_value("
            SELECT id FROM edit
              JOIN edit_$entity_type ON edit.id = edit_$entity_type.edit
             WHERE edit_$entity_type.$entity_type = ?
               AND edit.editor = ?
               AND edit.type = $create_edit_type
               AND (now() - edit.open_time) < interval '1 day'
        ", $amended_entity_id, $self->editor_id);

        return defined $add_entity_edit;
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014-2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
