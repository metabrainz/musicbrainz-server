package MusicBrainz::Server::Form::Field::Text;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Data::Utils;
use MusicBrainz::Server::Translation qw( l );

extends 'HTML::FormHandler::Field::Text';

after validate => sub {
    my $self = shift;

    my $value = $self->value;
    my $trimmed = MusicBrainz::Server::Data::Utils::trim($value);
    if (length $value && !length $trimmed) {
        # This error triggers if the entered text consists entirely of
        # invalid characters. However, text that is only whitespace
        # generally triggers the "Required field" error first.
        return $self->push_errors(
            l('The characters you’ve entered are invalid or not allowed.')
        );
    }
    $self->value($trimmed);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
