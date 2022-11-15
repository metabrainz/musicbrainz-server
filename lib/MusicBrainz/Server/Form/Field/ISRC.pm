package MusicBrainz::Server::Form::Field::ISRC;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_valid_isrc format_isrc );

extends 'HTML::FormHandler::Field::Text';

has '+minlength' => ( default => 12 );

apply ([
    {
        transform => sub { return format_isrc(shift) },
        message => sub { l('This is not a valid ISRC') },
    },
    {
        check => sub { is_valid_isrc(shift) },
        message => sub { l('This is not a valid ISRC.') },
    }
]);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
