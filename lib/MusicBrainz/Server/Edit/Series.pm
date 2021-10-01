package MusicBrainz::Server::Edit::Series;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation qw( lp );

sub edit_category { lp('Series', 'singular') }

1;
