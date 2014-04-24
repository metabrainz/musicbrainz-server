package MusicBrainz::Server::Edit::Instrument;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation 'l';

sub edit_category { l('Instrument') }

1;
