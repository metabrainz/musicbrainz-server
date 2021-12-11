package MusicBrainz::Server::Edit::WikiDoc;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Translation qw( l );

sub edit_category { l('Wiki documentation') }

1;
