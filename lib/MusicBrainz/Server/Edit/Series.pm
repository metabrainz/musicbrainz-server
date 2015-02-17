package MusicBrainz::Server::Edit::Series;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation 'lp';

sub edit_category { lp('Series', 'singular') }

1;
