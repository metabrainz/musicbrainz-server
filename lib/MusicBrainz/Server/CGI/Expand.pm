package MusicBrainz::Server::CGI::Expand;
use strict;
use warnings;
use base 'CGI::Expand';

# From CGI::Expand documentation:
#
#   The limit for the array size, defaults to 100. The value 0 can be used to
#   disable the use of arrays, everthing is a hash key.
#
# However, we do want arrays, so I've just set this to something Very Big.
sub max_array { 100000 }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
