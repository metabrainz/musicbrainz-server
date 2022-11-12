package MusicBrainz::Server::Form::Field::ID;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_database_row_id );

extends 'HTML::FormHandler::Field::Text';

apply([
    {
        check => sub { is_database_row_id(shift) },
        message => sub { l('This is not a valid database ID') }
    }
]);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
