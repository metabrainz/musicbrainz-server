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

sub list_open
{
    my ($self, $max, $offset) = @_;

    my $edit = new Moderation($self->dbh);
    my ($result, $edits) = $edit->moderation_list(q{
              SELECT m.*, NOW()>m.expiretime AS expired
                FROM moderation_open m
            ORDER BY m.id DESC
        }, undef, $offset, $max);

    return $edits;
}

sub count_open
{
    my ($self) = @_;

    my $edit = new Moderation($self->dbh);
    return $edit->OpenModCountAll;
}

1;
