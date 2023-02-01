package MusicBrainz::Server::Form::Field::ISWC;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_valid_iswc format_iswc );

extends 'HTML::FormHandler::Field::Text';

apply ([
    {
        transform => sub { return format_iswc(shift) },
        message => sub { l('This is not a valid ISWC') },
    },
    {
        check => sub { is_valid_iswc(shift) },
        message => sub { l('This is not a valid ISWC') },
    }
]);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
