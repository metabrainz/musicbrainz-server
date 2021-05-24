package MusicBrainz::DataStore;
use Moose::Role;

requires 'get';
requires 'set';
requires 'exists';
requires 'delete';

=method expire

Expire the specified key in $s seconds.

=cut

requires 'expire';

=method expire_at

Expire the specified key at (unix) $timestamp.

=cut

requires 'expire_at';

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

1;
