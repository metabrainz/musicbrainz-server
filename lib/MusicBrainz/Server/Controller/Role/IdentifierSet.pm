package MusicBrainz::Server::Controller::Role::IdentifierSet;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';
use MusicBrainz::Server::Data::Utils qw( type_to_model );

parameter 'entity_type' => (
    isa => 'Str',
    required => 1
);

parameter 'identifier_type' => (
    isa => 'Str',
    required => 1
);

parameter 'identifier_plural' => (
    isa => 'Maybe[Str]',
    required => 1,
    default => undef
);

parameter 'add_edit' => (
    isa => 'Int',
    required => 1
);

parameter 'remove_edit' => (
    isa => 'Int',
    required => 1
);

parameter 'include_source' => (
    isa => 'Bool',
    required => 1,
    default => 0
);

role
{
    my $params = shift;

    my $entity_type = $params->entity_type;
    my $identifier_type = $params->identifier_type;
    my $identifier_plural = $params->identifier_plural // $params->identifier_type . 's';

    my $add_edit = $params->add_edit;
    my $remove_edit = $params->remove_edit;

    my $include_source = $params->include_source;

    method _add_identifiers => sub {
        my ($self, $c, $form, $entity, @identifiers) = @_;

        $c->model('MB')->with_transaction(sub {
            $self->_insert_edit(
                $c, $form,
                edit_type => $add_edit,
                "$identifier_plural" => [ map {
                    "$identifier_type" => $_,
                    "$entity_type" => {
                        id => $entity->id,
                        name => $entity->name
                    },
                    $include_source ? (source   => 0) : ()
                }, @identifiers ]
            );
        });
    };

    method _remove_identifiers => sub {
        my ($self, $c, $form, $entity, @identifiers) = @_;

        $c->model('MB')->with_transaction(sub {
            $self->_insert_edit(
                $c, $form,
                edit_type => $remove_edit,
                $identifier_type => $_,
                $entity_type => $entity
            );
        }) for @identifiers;
    };

    method create_with_identifiers => sub {
        my ($self, $c) = @_;

        sub {
            my ($edit, $form) = @_;
            my $entity = $c->model(type_to_model($entity_type))->get_by_id($edit->entity_id);
            my @identifiers = @{ $form->field($identifier_plural)->value };
            $self->_add_identifiers($c, $form, $entity, @identifiers) if scalar @identifiers;
        };
    };

    method edit_with_identifiers => sub {
        my ($self, $c, $entity) = @_;

        sub {
            my ($edit, $form) = @_;

            my $find_by_entity = "find_by_${entity_type}s";
            my @current_identifiers = $c->model(type_to_model($identifier_type))->$find_by_entity($entity->id);
            my %current_identifiers = map { $_->$identifier_type => 1 } @current_identifiers;
            my @submitted = @{ $form->field($identifier_plural)->value };
            my %submitted = map { $_ => 1 } @submitted;

            my @added = grep { !exists($current_identifiers{$_}) } @submitted;
            my @removed = grep { !exists($submitted{$_->$identifier_type}) } @current_identifiers;

            $self->_add_identifiers($c, $form, $entity, @added) if @added;
            $self->_remove_identifiers($c, $form, $entity, @removed) if @removed;

            if ((@added || @removed) && $c->stash->{makes_no_changes}) {
                $c->stash( makes_no_changes => 0 );
                $c->response->redirect(
                    $c->uri_for_action($self->action_for('show'), [ $entity->gid ]));
            }
        };
    };
};

1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
