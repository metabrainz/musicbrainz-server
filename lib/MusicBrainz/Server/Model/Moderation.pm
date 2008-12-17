package MusicBrainz::Server::Model::Moderation;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model::Base';

use Moderation;
use MusicBrainz::Server::Vote;

sub load
{
    my ($self, $id) = @_;

    my $edit = new Moderation($self->dbh);
    $edit = $edit->CreateFromId($id);
    $edit->PreDisplay;

    return $edit;
}

sub insert
{
    my ($self, $edit_note, %opts) = @_;

    $opts{moderator} = $self->context->user;
    $opts{DBH}       = $self->context->mb->{DBH};

    my @mods = Moderation->InsertModeration(%opts);
    if (scalar @mods && $edit_note =~ /\S/)
    {
        $mods[0]->InsertNote($self->context->user->id, $edit_note)
    }

    return @mods;
}

sub list_open
{
    my ($self, $max, $offset) = @_;

    $max ||= 50;
    $offset ||= 0;

    my $edit = new Moderation($self->dbh);
    my ($result, $edits) = $edit->moderation_list(q{
              SELECT m.*, NOW()>m.expiretime AS expired
                FROM moderation_open m
            ORDER BY m.id DESC
        }, undef, $offset, $max);

    return $edits;
}

sub voted_on
{
    my ($self, $user, $max, $offset) = @_;

    $max ||= 50;
    $offset ||= 0;

    my $edit = Moderation->new($self->dbh);
    my ($result, $edits) = $edit->moderation_list(
        "SELECT m.*, NOW() > m.expiretime AS expired
           FROM moderation_all m
     INNER JOIN vote_all v ON v.moderation = m.id
            AND v.moderator = " . $user->id . "
        AND NOT v.superseded
       ORDER BY m.id DESC", undef, $offset, $max);

    return $edits;
}

sub count_open
{
    my ($self) = @_;

    my $edit = new Moderation($self->dbh);
    return $edit->OpenModCountAll;
}

sub top_voters
{
    my $self = shift;
    my ($limit) = @_;

    my $vote = MusicBrainz::Server::Vote->new($self->dbh);
    return $vote->TopVoters(
         rowlimit => $limit,
         interval => "1 Week",
    );
}

1;
