package MusicBrainz::Server::Form::Role::ToJSON;

use JSON;
use Moose::Role;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );

sub TO_JSON {
    my ($self) = @_;

    my $json = {
        has_errors => boolean_to_json($self->has_errors),
    };

    if ($self->isa('HTML::FormHandler')) {
        $json->{name} = $self->name;
    }

    if ($self->isa('HTML::FormHandler::Field')) {
        # On the form, `errors` is a list.
        $json->{errors} = $self->errors;
    }

    if ($self->can('fields')) {
        if ($self->isa('HTML::FormHandler::Field::Repeatable')) {
            $json->{field}[$_->name] = TO_JSON($_) for $self->fields;
        } else {
            $json->{field}{$_->name} = TO_JSON($_) for $self->fields;
        }
    } else {
        $json->{value} = $self->value;
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
