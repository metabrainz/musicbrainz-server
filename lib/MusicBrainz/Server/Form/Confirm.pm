package MusicBrainz::Server::Form::Confirm;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub profile {
    return shift->with_mod_fields({});
}

1;
