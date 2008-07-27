package MusicBrainz::Server::Facade::Entity;

use strict;
use warnings;

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw{ name id mbid entity_type });

1;
