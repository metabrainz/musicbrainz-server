package MusicBrainz::Server::Edit::ReleaseGroup;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation 'l';

sub edit_category { l('Release group') }

1;
