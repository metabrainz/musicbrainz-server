package MusicBrainz::ErrorCatcherEmailWrapper;

use strict;
use warnings;

use Catalyst::Plugin::ErrorCatcher::Email;

our $suppress = 0;

sub emit {
    my ($class, $c, $output) = @_;

    if ($suppress) {
        return; # will cause ErrorCatcher to log the error instead
    } else {
        Catalyst::Plugin::ErrorCatcher::Email->emit($c, $output);
        return 1;
    }
}

1;

=head1 DESCRIPTION

Wrapper around C<Catalyst::Plugin::ErrorCatcher::Email> that allows
deactivating the emitter on a case-by-case basis. When you do not want
for an email to be sent, use C<local> to temporarily give C<$suppress>
a true value.

=head1 COPYRIGHT

Copyright (C) 2015 Ulrich Klauer

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 2 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
MA 02110-1301, USA.

=cut
