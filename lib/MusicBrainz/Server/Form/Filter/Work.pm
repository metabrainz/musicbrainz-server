package MusicBrainz::Server::Form::Filter::Work;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l lp );
extends 'MusicBrainz::Server::Form::Filter::Generic';

has 'languages' => (
    isa => 'ArrayRef[Language]',
    is => 'ro',
    required => 1,
);

has 'types' => (
    isa => 'ArrayRef[WorkType]',
    is => 'ro',
    required => 1,
);

has_field 'role_type' => (
    type => 'Select',
);

has_field 'language_id' => (
    type => 'Select',
);

has_field 'type_id' => (
    type => 'Select',
);

sub filter_field_names {
    return qw/ disambiguation name role_type language_id type_id /;
}

sub options_role_type {
    return [
        { value => 1, label => l('As performer') },
        { value => 2, label => l('As writer') },
    ];
}

sub options_language_id {
    my ($self, $field) = @_;
    return [
        { value => '-1', label => lp('[not set]', 'language') },
        map +{
            value => $_->id,
            label => $_->iso_code_3 && $_->iso_code_3 eq 'zxx'
                        ? l('[No lyrics]')
                        : $_->l_name,
        },
        @{ $self->languages },
    ];
}

sub options_type_id {
    my ($self, $field) = @_;
    return [
        { value => '-1', label => lp('[none]', 'work type') },
        map +{ value => $_->id, label => $_->l_name },
        @{ $self->types },
    ];
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{options_role_type} = $self->options_role_type;
    $json->{options_language_id} = $self->options_language_id;
    $json->{options_type_id} = $self->options_type_id;
    return $json;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
