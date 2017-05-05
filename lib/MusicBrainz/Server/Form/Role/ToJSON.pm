package MusicBrainz::Server::Form::Role::ToJSON;

use JSON;
use Moose::Role;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );

requires qw( name fields );

sub TO_JSON {
    my ($self) = @_;

    my $result = {
        name => $self->name,
    };
    for my $field ($self->fields) {
        $result->{field}{$field->name} = {
            errors => $field->errors,
            has_errors => boolean_to_json($field->has_errors),
            html_name => $field->html_name,
            label => $field->label,
            value => $field->value,
            ($field->can('error_fields') ? (
                error_fields => [
                    map +{ errors => $_->errors }, $field->error_fields,
                ],
            ) : ()),
        };
    }
    return $result;
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
