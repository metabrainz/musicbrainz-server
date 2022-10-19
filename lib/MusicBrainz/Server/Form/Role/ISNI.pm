package MusicBrainz::Server::Form::Role::ISNI;
use strict;
use warnings;

use HTML::FormHandler::Moose::Role;

use List::AllUtils qw( uniq );

has_field 'isni_codes'          => (
    type => 'Repeatable',
    num_when_empty => 1,
    inflate_default_method => \&inflate_isni_codes
);

has_field 'isni_codes.contains' => (
    type => '+MusicBrainz::Server::Form::Field::ISNI'
);

after 'validate' => sub {
    my ($self) = @_;
    return if $self->has_errors;

    {
        my $isni_codes_field =  $self->field('isni_codes');
        $isni_codes_field->value(
            [ uniq sort grep { $_ } @{ $isni_codes_field->value } ]
        );
    };
};

sub inflate_isni_codes {
    my ($self, $value) = @_;
    return [ map { $_->isni } @$value ];
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
