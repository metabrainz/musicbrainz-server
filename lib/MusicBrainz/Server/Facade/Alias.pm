package MusicBrainz::Server::Facade::Alias;

use strict;
use warnings;

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw{
    last_used
    times_used
    name
});

1;
