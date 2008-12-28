package MusicBrainz::Server::Model::FreeDB;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model';

use FreeDB;

sub load
{
    my ($self, $id, $category) = @_;

    my $free_db = FreeDB->new($self->dbh);
    return $free_db->LookupByFreeDBId($id, $category);
}

1;
