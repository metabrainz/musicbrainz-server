package MusicBrainz::Server::Facade::Link;

use strict;
use warnings;

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw{
    entity_type
    name
    mbid
    url
});

1;
