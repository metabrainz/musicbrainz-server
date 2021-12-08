package MusicBrainz::Server::Edit::Event;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation qw ( l );

sub edit_category { l('Event') }

1;
