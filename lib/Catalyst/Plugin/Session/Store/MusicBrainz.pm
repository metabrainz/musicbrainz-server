package Catalyst::Plugin::Session::Store::MusicBrainz;
use Moose;
use MusicBrainz::DataStore::Redis;
use Try::Tiny;
use MIME::Base64 qw(encode_base64 decode_base64);
use Storable qw/nfreeze thaw/;

extends 'Catalyst::Plugin::Session::Store';

has '_datastore' => (
    is => 'rw',
    does => 'MusicBrainz::DataStore',
    default => sub { return MusicBrainz::DataStore::Redis->new; }
);

sub get_session_data {
    my ($self, $key) = @_;

    if(my ($sid) = $key =~ /^expires:(.*)/)
    {
        return $self->_datastore->get ($key);
    }
    else
    {
        my $data = $self->_datastore->get ($key);
        return thaw (decode_base64 ($data)) if defined $data;
    }
}

sub store_session_data {
    my ($self, $key, $data) = @_;

    if(my ($sid) = $key =~ /^expires:(.*)/)
    {
        $self->_datastore->set ($key, $data);
    }
    else
    {
        $self->_datastore->set ($key, encode_base64 (nfreeze($data)));
        $self->_datastore->expireat($key, $self->session_expires);
    }
}

sub delete_session_data {
    my ($self, $key) = @_;

    $self->_datastore->del ($key);
}

sub delete_expired_sessions { }

=head1 LICENSE

Copyright 2013 MetaBrainz Foundation

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
