package MusicBrainz::Server::Model::Moderation;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model::Base';

sub load
{
    my ($self, $id) = @_;

    my $edit = new Moderation($self->dbh);
    $edit = $edit->CreateFromId($id);
    $edit->PreDisplay;

    return $edit;
}

1;
