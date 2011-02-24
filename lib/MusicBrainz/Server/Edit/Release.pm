package MusicBrainz::Server::Edit::Release;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation 'l';

sub edit_category { l('Release') }

1;
