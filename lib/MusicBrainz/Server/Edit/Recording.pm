package MusicBrainz::Server::Edit::Recording;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation qw ( l );

sub edit_category { l('Recording') }

1;
