package MusicBrainz::Server::Form::Field::LabelCode;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Form::Field::Integer';

apply(
    [
        {
            check   => sub { $_[0] > 0 && $_[0] < 100000 },
            message => sub {
                my ( $value, $field ) = @_;
                return l('Label codes must be greater than 0 and 5 digits at most');
            },
        }
    ]
);

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
