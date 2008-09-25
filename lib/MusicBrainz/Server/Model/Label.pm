package MusicBrainz::Server::Model::Label;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model::Base';

use Carp;
use MusicBrainz::Server::Adapter 'LoadEntity';

sub load
{
    my ($self, $id) = @_;

    my $label = MusicBrainz::Server::Label->new($self->dbh);
    LoadEntity($label, $id);

    return $label;
}

1;
