package MusicBrainz::Server::Model::Url;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model::Base';

use Carp;
use MusicBrainz::Server::Adapter 'LoadEntity';
use MusicBrainz::Server::Facade::Url;
use MusicBrainz::Server::Validation;
use MusicBrainz::Server::URL;

sub load
{
    my ($self, $id) = @_;

    my $url = MusicBrainz::Server::URL->new($self->dbh);
    LoadEntity($url, $id);

    return MusicBrainz::Server::Facade::Url->new_from_url($url);
}

1;
