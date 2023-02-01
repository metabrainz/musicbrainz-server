package MusicBrainz::Server::Form::Field::Barcode;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Validation;

extends 'HTML::FormHandler::Field::Text';

has '+maxlength' => (
    default => 255
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
