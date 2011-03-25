package MusicBrainz::Server::Edit::Work;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation 'l';

sub edit_category { l('Work') }

1;
