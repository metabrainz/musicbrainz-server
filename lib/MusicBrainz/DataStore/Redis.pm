package MusicBrainz::DataStore::Redis;

use Moose;
use DBDefs;
use Encode;
use Redis;
use JSON;

extends 'MusicBrainz::Redis';

with 'MusicBrainz::DataStore';

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    if (@_) {
        return $class->$orig(@_);
    }

    my $args = DBDefs->DATASTORE_REDIS_ARGS;
    if (ref($args) eq 'ARRAY') {
        die 'Use DataStore::RedisMulti to support an array in DATASTORE_REDIS_ARGS.';
    }
    return $class->$orig($args);
};

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

1;
