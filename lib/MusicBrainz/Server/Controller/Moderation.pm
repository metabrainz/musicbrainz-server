package MusicBrainz::Server::Controller::Moderation;

use strict;
use warnings;

use base 'Catalyst::Controller';

use DBDefs;

=head1 NAME

MusicBrainz::Server::Controller::Moderation - handle user interaction
with moderations

=head1 DESCRIPTION

This controller allows editors to view moderations, and vote on open
moderations.

=head1 ACTIONS

=head2 moderation

Root of chained actions that work with a single moderation. Cannot be
called on its own.

=cut

sub moderation : Chained CaptureArgs(1)
{
    my ($self, $c, $mod_id) = @_;

    my $moderation = $c->model('Moderation')->load($mod_id);
    $c->stash->{moderation} = $moderation;
}

=head2 list

Show all open moderations in chronological order.

=cut

sub show : Chained('moderation')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    $c->stash->{expire_action} = \&ModDefs::GetExpireActionText;

    my $moderation = $c->stash->{moderation};

    if (defined $moderation->{'trackid'})
    {
        my $track = $c->model('Track')->load($moderation->{'trackid'});
        $c->stash->{track} = $track;
    }

    if (defined $moderation->{'albumid'})
    {
        my $release = $c->model('Release')->load($moderation->{'albumid'});
        $c->stash->{release} = $release;
    }

    unless ($moderation->{'dont-display-artist'})
    {
        $c->stash->{artist} = $moderation->artist;
    }


    my $comp = ref $moderation;
    $comp =~ s/.*::MOD_(.*)/$1/;

    $c->stash->{template    } = 'moderation/show.tt';
    $c->stash->{mod_template} = lc $comp;
}

=head2 approve

Approve action for staging servers (not available on master servers).

=cut

sub approve : Chained('moderation')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    die "Approve is only available on test servers"
        unless DBDefs::REPLICATION_TYPE eq MusicBrainz::Server::Replication::RT_STANDALONE;

    my $moderation = $c->stash->{moderation};

    my $vertmb = new MusicBrainz;
    $vertmb->Login(db => 'RAWDATA');

    my $vertsql = Sql->new($vertmb->{DBH});
    my $sql     = Sql->new($c->mb->{DBH});

    $sql->Begin;
    $vertsql->Begin;

    $Moderation::DBConnections{READWRITE} = $sql;
    $Moderation::DBConnections{RAWDATA} = $vertsql;

    my $status = $moderation->ApprovedAction;
    $moderation->status($status);

    my $user = $c->model('User')->load_user({ id => $moderation->moderator });
    $user->CreditModerator($moderation->moderator, $status);

    $moderation->CloseModeration($status);

    delete $Moderation::DBConnections{READWRITE};
    delete $Moderation::DBConnections{RAWDATA};

    $vertsql->Commit;
    $sql->Commit;

    # Reload moderation
    $moderation = $c->model('Moderation')->load($moderation->id);
    $c->stash->{moderation} = $moderation;

    $c->flash->{ok} = "Moderation approved";

    $c->forward('show');
}

=head2 reject

Reject action for staging servers (not available on master servers).

=cut

sub reject : Chained('moderation')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    die "Reject is only available on test servers"
        unless DBDefs::REPLICATION_TYPE eq MusicBrainz::Server::Replication::RT_STANDALONE;

    my $moderation = $c->stash->{moderation};

    my $vertmb = new MusicBrainz;
    $vertmb->Login(db => 'RAWDATA');

    my $vertsql = Sql->new($vertmb->{DBH});
    my $sql     = Sql->new($c->mb->{DBH});

    $sql->Begin;
    $vertsql->Begin;

    $Moderation::DBConnections{READWRITE} = $sql;
    $Moderation::DBConnections{RAWDATA} = $vertsql;

    my $status = $moderation->DeniedAction;
    $moderation->status($status);

    my $user = $c->model('User')->load_user({ id => $moderation->moderator });
    $user->CreditModerator($moderation->moderator, $status);

    $moderation->CloseModeration($status);

    delete $Moderation::DBConnections{READWRITE};
    delete $Moderation::DBConnections{RAWDATA};

    $vertsql->Commit;
    $sql->Commit;

    # Reload moderation
    $moderation = $c->model('Moderation')->load($moderation->id);
    $c->stash->{moderation} = $moderation;

    $c->flash->{ok} = "Moderation approved";

    $c->forward('show');
}

=head2 open

Show a list of open moderations

=cut

sub open : Local
{
    my ($self, $c) = @_;

    $c->stash->{edits} = $c->model('Moderation')->list_open(25, 0);
}

1;
