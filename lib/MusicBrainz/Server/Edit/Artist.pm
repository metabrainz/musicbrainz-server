package MusicBrainz::Server::Edit::Artist;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation qw ( l );

sub edit_category { l('Artist') }

1;
