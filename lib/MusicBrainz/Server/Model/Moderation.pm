package MusicBrainz::Server::Model::Moderation;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model';

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
    $opts{dbh} = $self->context->mb->dbh;

    my @mods = Moderation->InsertModeration(%opts);
    if (scalar @mods && $edit_note =~ /\S/)
    {
        $mods[0]->InsertNote($self->context->user->id, $edit_note)
    }

    return @mods;
}

sub _query_with_pager
{
    my ($self, $query, $page, $per_page) = @_;
    
    $per_page ||= 50;
    
    my $pager = Data::Page->new;
    $pager->current_page($page);
    $pager->entries_per_page($per_page);
    
    my $edit = new Moderation($self->dbh);
    my $offset = ($page - 1) * $per_page;
    my ($result, $edits, $rows) = $edit->moderation_list($query, undef, $offset, $per_page);
    
    $pager->total_entries($rows);

    return ($edits, $pager);
}

sub list_open
{
    my ($self, $page, $per_page) = @_;

    return $self->_query_with_pager(q{
              SELECT m.*, NOW()>m.expiretime AS expired
                FROM moderation_open m
            ORDER BY m.id DESC
        }, $page, $per_page);
}

sub voted_on
{
    my ($self, $user, $page, $per_page) = @_;

    my $edit = Moderation->new($self->dbh);
    return $self->_query_with_pager(
        "SELECT m.*, NOW() > m.expiretime AS expired, v.vote
           FROM moderation_all m
     INNER JOIN vote_all v ON v.moderation = m.id
            AND v.moderator = " . $user->id . "
        AND NOT v.superseded
       ORDER BY m.id DESC", $page, $per_page);
}

sub edits_for_entity
{
    my ($self, $entity, $page, $per_page) = @_;

    return $self->_query_with_pager(
        "SELECT m.*, NOW() > m.expiretime AS expired
           FROM moderation_all m
          WHERE m.rowid = " . $entity->id . "
       ORDER BY m.id DESC", $page, $per_page);
}

sub users_edits
{
    my ($self, $user, $type, $page, $per_page) = @_;

    my @status = $type eq 'closed'    ? ( ModDefs::STATUS_APPLIED )
               : $type eq 'failed'    ? ( ModDefs::STATUS_FAILEDVOTE, ModDefs::STATUS_FAILEDDEP, ModDefs::STATUS_FAILEDPREREQ )
               : $type eq 'open'      ? ( ModDefs::STATUS_OPEN )
               : $type eq 'cancelled' ? ( ModDefs::STATUS_DELETED )
               : $type eq 'all'       ? ( ModDefs::STATUS_OPEN, ModDefs::STATUS_APPLIED )
               :                        ( ModDefs::STATUS_OPEN, ModDefs::STATUS_APPLIED );

    my $table = $type eq 'open'   ? 'open'
              : $type eq 'closed' || $type eq 'failed' || $type eq 'cancelled' ? 'closed'
              : $type eq 'all' ? 'all'
              : 'all';

    return $self->_query_with_pager(
        "SELECT m.*, NOW() > m.expiretime AS expired
           FROM moderation_$table m
          WHERE m.moderator = " . $user->id . "
            AND m.status IN ( ". join(",",@status) .")
       ORDER BY m.id DESC", $page, $per_page);
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
    my ($limit, $interval) = @_;

    $interval ||= '1 week';

    my $vote = MusicBrainz::Server::Vote->new($self->dbh);
    return $vote->TopVoters(
         rowlimit => $limit,
         interval => "1 Week",
    );
}

sub top_moderators
{
    my ($self, $limit) = @_;

    my $mod = Moderation->new($self->dbh);
    return $mod->TopModerators(
         rowlimit  => $limit,
         namelimit => $limit,
    );
}

sub top_moderators_overall
{
    my ($self, $limit) = @_;

    my $mod = Moderation->new($self->dbh);
    return $mod->TopAcceptedModeratorsAllTime(
         rowlimit  => $limit,
         namelimit => $limit,
    );
}

1;
