package MusicBrainz::Server::Edit::Label;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation qw ( l );

sub edit_category { l('Label') }

1;
