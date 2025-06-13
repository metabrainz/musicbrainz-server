package MusicBrainz::Server::Controller::Role::IdentifierSet;
use MooseX::MethodAttributes::Role;
use MooseX::Role::Parameterized;
use namespace::autoclean;
use List::AllUtils qw( sort_by uniq uniq_by );
use MusicBrainz::Server::Data::Utils qw( type_to_model );

parameter 'entity_type' => (
    isa => 'Str',
    required => 1,
);

parameter 'identifier_type' => (
    isa => 'Str',
    required => 1,
);

parameter 'identifier_plural' => (
    isa => 'Maybe[Str]',
    required => 1,
    default => undef,
);

parameter 'add_edit' => (
    isa => 'Int',
    required => 1,
);

parameter 'remove_edit' => (
    isa => 'Int',
    required => 1,
);

parameter 'include_source' => (
    isa => 'Bool',
    required => 1,
    default => 0,
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
                        name => $entity->name,
                    },
                    $include_source ? (source   => 0) : ()
                }, @identifiers ],
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
                $entity_type => $entity,
            );
        }) for @identifiers;
    };

    # Prior to MBS-13969, the `isrcs`/`iswcs`` form fields were simple
    # repeatable text fields, e.g., `isrcs.0=USS1Z9900001`. In order to
    # prevent submitting unintended removals for these identifiers when the
    # fields are omitted, a `removed` subfield was added to explicitly
    # indicate removals, like `$identifier.0.removed=1`.
    #
    # `HTML::FormHandler` doesn't obviously support subfields on text fields,
    # so these have to be converted to repeatable compound fields containing
    # `value` (the identifier) and `removed` subfields.
    #
    # At the same time, we're keeping `$identifier.N` as seedable and
    # submittable text fields for backwards compatibility with external
    # tools. In order to do this, we have to munge `$identifier.N` into
    # `$identifier.N.value` within the POST parameters before the underlying
    # form sees it.
    method munge_compound_text_fields => sub {
        my ($self, $c, $form) = @_;
        my $field_name = $form->field($identifier_plural)->html_name;
        for my $params_prop (qw( query_params body_params )) {
            my %params = %{ $c->req->$params_prop };
            for my $param (keys %params) {
                if ($param =~ /^$field_name\.([0-9]+)$/) {
                    $params{"$field_name.$1.value"} = $params{$param};
                    delete $params{$param};
                }
            }
            $c->req->$params_prop(\%params);
        }
    };

    method get_current_identifiers => sub {
        my ($self, $c, $entity_id) = @_;
        my $find_by_entity = "find_by_${entity_type}s";
        return $c->model(type_to_model($identifier_type))->$find_by_entity($entity_id);
    };

    method stash_current_identifier_values => sub {
        my ($self, $c, $entity_id) = @_;
        $c->stash->{"current_${identifier_plural}"} = [
            map { $_->$identifier_type } $self->get_current_identifiers($c, $entity_id),
        ];
    };

    method create_with_identifiers => sub {
        my ($self, $c) = @_;

        sub {
            my ($edit, $form) = @_;
            my $entity = $c->model(type_to_model($entity_type))->get_by_id($edit->entity_id);
            my @identifiers = (
                uniq
                map { $_->{value} }
                grep { !$_->{removed} }
                @{ $form->field($identifier_plural)->value },
            );
            $self->_add_identifiers($c, $form, $entity, @identifiers) if scalar @identifiers;

            return scalar @identifiers;
        };
    };

    method edit_with_identifiers => sub {
        my ($self, $c, $entity) = @_;

        sub {
            my ($edit, $form) = @_;

            my %current_identifiers = map {
                $_->$identifier_type => $_
            } $self->get_current_identifiers($c, $entity->id);
            my @submitted = @{ $form->field($identifier_plural)->value };

            my %added;
            my @removed;
            for my $field (@submitted) {
                my $value = $field->{value};
                if ($field->{removed}) {
                    my $existing = $current_identifiers{$value};
                    if (defined $existing) {
                        push @removed, $existing;
                    }
                } else {
                    $added{$value} = 1;
                }
            }

            @removed = (
                sort_by { $_->$identifier_type }
                uniq_by { $_->$identifier_type }
                grep { !exists $added{ $_->$identifier_type } }
                @removed,
            );
            my @non_existing_added = sort { $a cmp $b } uniq grep {
                !exists $current_identifiers{$_}
            } keys %added;

            $self->_add_identifiers($c, $form, $entity, @non_existing_added)
                if @non_existing_added;
            $self->_remove_identifiers($c, $form, $entity, @removed) if @removed;

            return (@non_existing_added || @removed);
        };
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
