package Catalyst::Plugin::Session::Store::MusicBrainz;
use Moose;
use namespace::autoclean;
use MusicBrainz::DataStore::RedisMulti;
use MIME::Base64 qw(encode_base64 decode_base64);
use Storable qw/nfreeze thaw/;

extends 'Catalyst::Plugin::Session::Store';

has '_datastore' => (
    is => 'rw',
    does => 'MusicBrainz::DataStore',
    default => sub { return MusicBrainz::DataStore::RedisMulti->new; }
);

sub get_session_data {
    my ($self, $key) = @_;

    if ($key =~ /^expires:(.*)/)
    {
        return $self->_datastore->get($key);
    }
    else
    {
        my $data = $self->_datastore->get($key);
        return thaw(decode_base64($data)) if defined $data;
    }
}

sub store_session_data {
    my ($self, $key, $data) = @_;

    unless ($key =~ /^expires:/) {
        $data = encode_base64(nfreeze($data));
    }
    $self->_datastore->set($key, $data);
    $self->_datastore->expire_at($key, $self->session_expires);
}

sub delete_session_data {
    my ($self, $key) = @_;

    $self->_datastore->delete($key);
}

sub delete_expired_sessions { }

=head1 COPYRIGHT AND LICENSE

Copyright 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

1;
