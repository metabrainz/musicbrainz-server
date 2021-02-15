package MusicBrainz::Server::Edit::Role::Preview;
use Moose::Role;

has 'preview' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

