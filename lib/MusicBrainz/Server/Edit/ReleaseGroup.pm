package MusicBrainz::Server::Edit::ReleaseGroup;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation qw ( l );

sub edit_category { l('Release group') }

1;
