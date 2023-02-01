## no critic (RequireFilenameMatchesPackage)
package MusicBrainz::Server::WebService::Exceptions::UnknownIncParameter;
use Moose;
with 'Throwable';

has parameter => ( is => 'ro', required => 1, isa => 'Str' );

sub message { sprintf 'Unknown inc parameter: %s', shift->parameter }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
