package MusicBrainz::Server::Edit::Series;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation 'l';

sub edit_category { l('Series') }

1;
