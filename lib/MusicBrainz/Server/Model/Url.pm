package MusicBrainz::Server::Model::Url;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model';

use Carp;
use MusicBrainz::Server::Adapter 'LoadEntity';
use MusicBrainz::Server::Validation;
use MusicBrainz::Server::URL;

sub load
{
    my ($self, $id) = @_;

    my $url = MusicBrainz::Server::URL->new($self->dbh);
    $url = LoadEntity($url, $id);

    return $url;
}

1;
