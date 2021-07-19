package MusicBrainz::Server::Form::Role::ToJSON;

use feature 'state';
use JSON;
use Moose::Role;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );

sub TO_JSON {
    my ($self) = @_;

    # We assign a unique ID on each field for use as React key props when
    # rendering. Loops indexes and field values are not usable for this
    # purpose, because the order of the fields can change, and their values
    # do not uniquely identify them.
    # https://reactjs.org/docs/lists-and-keys.html#keys
    state $field_id_counter;

    my $json = {
        has_errors => boolean_to_json($self->has_errors),
    };

    my $is_form = $self->isa('HTML::FormHandler');
    if ($is_form) {
        $field_id_counter = 0;
        $json->{name} = $self->name;
        $json->{type} = 'form';
    }

    if ($self->isa('HTML::FormHandler::Field')) {
        # On the form, `errors` is a list.
        $json->{errors} = $self->errors;
        $json->{html_name} = $self->html_name;
        $json->{id} = ++$field_id_counter;
        $json->{type} = 'field';
    }

    if ($self->can('fields')) {
        if ($self->isa('HTML::FormHandler::Field::Repeatable')) {
            $json->{field} = [];
            $json->{field}[$_->name] = TO_JSON($_) for $self->fields;
            $json->{last_index} = scalar(@{ $json->{field} }) - 1;
            $json->{type} = 'repeatable_field';
        } else {
            $json->{field} = {};
            $json->{field}{$_->name} = TO_JSON($_) for $self->fields;
            $json->{type} = 'compound_field';
        }
    } else {
        if ($self->isa('HTML::FormHandler::Field::Checkbox')) {
            $json->{value} = boolean_to_json($self->value);
        } else {
            $json->{value} = $self->fif;
        }
    }

    if ($is_form) {
        $field_id_counter = 0;
    }

    return $json;
}

sub to_encoded_json {
    JSON->new->utf8(0)->encode(shift->TO_JSON);
}

no Moose::Role;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt
