package Catalyst::Plugin::Session::Store::MusicBrainz;

use Catalyst::Plugin::Session::Store::Memcached;
our @ISA = 'Catalyst::Plugin::Session::Store::Memcached';

sub store_session_data
{
    my $self = shift;
    my $ret;

    eval {
        $ret = $self->SUPER::store_session_data(@_);
    };
    if ($@)
    {
        $self->log->error ("Cannot save session to memcached, kick some servers!");
    }

    return $ret;
}

=head1 LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut

1;


