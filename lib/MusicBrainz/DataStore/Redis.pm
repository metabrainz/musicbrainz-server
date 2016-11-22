package MusicBrainz::DataStore::Redis;

use Moose;
use DBDefs;
use Encode;
use Redis;
use JSON;

extends 'MusicBrainz::Redis';

with 'MusicBrainz::DataStore';

sub BUILDARGS {
    my ($class, %args) = @_;

    return \%args if %args;
    return DBDefs->DATASTORE_REDIS_ARGS;
}

has '_json' => (
    is => 'ro',
    default => sub {
        JSON->new->allow_nonref->allow_blessed->convert_blessed->ascii;
    }
);

sub _encode_value {
    my ($self, $value) = @_;

    return $self->_json->encode($value);
}

sub _decode_value {
    my ($self, $value) = @_;

    return defined $value ? $self->_json->decode($value) : undef;
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
