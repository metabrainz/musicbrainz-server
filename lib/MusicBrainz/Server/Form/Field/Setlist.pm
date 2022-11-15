package MusicBrainz::Server::Form::Field::Setlist;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_valid_setlist );

extends 'HTML::FormHandler::Field::Text';

apply ([
    {
        check => sub { is_valid_setlist(shift) },
        message => sub { l('Please ensure all lines start with @, * or #, followed by a space.') },
    }
]);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
