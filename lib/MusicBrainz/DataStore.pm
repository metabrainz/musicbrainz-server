package MusicBrainz::DataStore;
use Moose;

sub get    { die("Not implemented"); }
sub set    { die("Not implemented"); }
sub exists { die("Not implemented"); }
sub del    { die("Not implemented"); }
sub expire { die("Not implemented"); }

=method incr

Increment the value for the $key.

=cut

sub incr {
    my ($self, $key, $increment) = @_;

    my $newvalue = $self->get ($key) + ($increment // 1);
    $self->set ($key, $newvalue);

    return $newvalue;
}

=method add

Store the $value on the server under the $key, but only if the key
doesn't exists on the server.

=cut

sub add {
    my ($self, $key, $value) = @_;

    return if $self->exists ($key);

    return $self->set ($key, $value);
}


=head1 LICENSE

Copyright (C) 2013 MetaBrainz Foundation

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

