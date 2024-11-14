package MusicBrainz::Server::Form::Field::ISO_3166_1;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_valid_iso_3166_1 );

extends 'HTML::FormHandler::Field::Text';

apply ([
    {
        check => sub { is_valid_iso_3166_1(shift) },
        message => sub { l('This is not a valid ISO 3166-1 code') },
    },
]);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
