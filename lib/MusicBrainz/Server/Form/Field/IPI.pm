package MusicBrainz::Server::Form::Field::IPI;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_valid_ipi format_ipi );

extends 'HTML::FormHandler::Field::Text';

apply ([
    {
        transform => sub { return format_ipi(shift) },
        message => sub { l('This is not a valid IPI.') },
    },
    {
        check => sub { is_valid_ipi(shift) },
        message => sub { l('This is not a valid IPI.') },
    }
]);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
