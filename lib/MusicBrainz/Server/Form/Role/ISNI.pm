package MusicBrainz::Server::Form::Role::ISNI;
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

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

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
