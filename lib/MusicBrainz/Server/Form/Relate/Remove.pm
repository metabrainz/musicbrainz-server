package MusicBrainz::Server::Form::Relate::Remove;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub profile {
    return shift->with_mod_fields({});
}

1;
