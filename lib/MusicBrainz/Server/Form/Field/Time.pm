package MusicBrainz::Server::Form::Field::Time;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_valid_time );

extends 'HTML::FormHandler::Field::Text';

has '+deflate_method' => (
    default => sub { \&format_time }
);

apply ([
    {
        check => sub { is_valid_time(shift) },
        message => sub { l('This is not a valid time.') },
    }
]);

sub format_time {
    my ($self, $value) = @_;
    return $value ? $value->strftime('%H:%M') : undef;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
