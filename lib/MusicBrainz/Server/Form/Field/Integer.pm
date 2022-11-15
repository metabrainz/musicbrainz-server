package MusicBrainz::Server::Form::Field::Integer;
use Moose;
use HTML::FormHandler::Moose;
use namespace::autoclean;

extends 'HTML::FormHandler::Field::Integer';

apply([
    {
        transform => sub {
            my $value = shift;
            return 0 + $value;
        },
        message => '',
    }
]);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
