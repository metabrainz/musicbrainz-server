package MusicBrainz::Server::Controller::Moderation;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

use DBDefs;
use MusicBrainz::Server::Vote;

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
    $c->stash->{moderation} = $c->model('Moderation')->load($mod_id);
}

=head2 list

Show all open moderations in chronological order.

=cut

sub show : Chained('moderation')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    use MusicBrainz::Server::Form::Moderation::AddNote;
    my $add_note = MusicBrainz::Server::Form::Moderation::AddNote->new;

    $c->stash->{add_note} = $add_note;

    $c->stash->{expire_action} = \&ModDefs::GetExpireActionText;
    $c->stash->{template     } = 'moderation/show.tt';
}

=head2 add_note

Add a moderation note to an existing edit

=cut

sub add_note : Chained('moderation') Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $moderation = $c->stash->{moderation};

    my $form = $self->form;
    $form->init($moderation);

    return unless $c->form_posted && $form->validate($c->req->params);

    $form->insert;

    $c->response->redirect($c->entity_url($moderation, 'show'));
}

=head2 vote

POST only method to enter votes on a moderation

=cut

sub enter_votes : Local
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    return unless $c->form_posted;

    my %votes;

    while(my ($field, $vote) = each %{ $c->req->params })
    {
        my ($id) = $field =~ m/vote_(\d+)/;
        if (defined $id)
        {
            $votes{$id} = $vote eq 'y' ? ModDefs::VOTE_YES
                        : $vote eq 'n' ? ModDefs::VOTE_NO
                        : $vote eq 'a' ? ModDefs::VOTE_ABS
                        : ModDefs::VOTE_NOTVOTED;
        }
    }

    my $sql  = new Sql($c->mb->{dbh});
    my $vote = new MusicBrainz::Server::Vote($c->mb->{dbh});

    eval
    {
        $sql->Begin;
        $vote->InsertVotes(\%votes, $c->user->id);
        $sql->Commit;
    };

    if ($@)
    {
        my $err = $@;
        $sql->Rollback;

        die "Could not enter vote: $err";
    }

    $c->forward('/moderation/open');
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

    my $vertsql = Sql->new($vertmb->{dbh});
    my $sql     = Sql->new($c->mb->{dbh});

    $sql->Begin;
    $vertsql->Begin;

    $Moderation::DBConnections{READWRITE} = $sql;
    $Moderation::DBConnections{RAWDATA} = $vertsql;

    my $status = $moderation->ApprovedAction;
    $moderation->status($status);

    my $user = $moderation->moderator;
    $user->CreditModerator($user->id, $status);

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

    my $vertsql = Sql->new($vertmb->{dbh});
    my $sql     = Sql->new($c->mb->{dbh});

    $sql->Begin;
    $vertsql->Begin;

    $Moderation::DBConnections{READWRITE} = $sql;
    $Moderation::DBConnections{RAWDATA} = $vertsql;

    my $status = $moderation->DeniedAction;
    $moderation->status($status);

    my $user = $c->model('User')->load({ id => $moderation->moderator });
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

    $c->forward('/user/login');

    use POSIX qw/ceil floor/;

    my $offset = $c->req->query_params->{offset} || 0;
    my $limit  = $c->req->query_params->{limit} || 25;

    $limit = $limit > 100 ? 100 : $limit;
    $limit = $limit < 25  ? 25  : $limit;

    $offset = $offset < 0 ? 0 : $offset;

    my $current_page = floor($offset / $limit) + 1;

    my $edits      = $c->model('Moderation')->list_open($limit, $offset);
    my $total_open = $c->model('Moderation')->count_open();

    $c->stash->{current_page} = $current_page;
    $c->stash->{total_pages}  = ceil($total_open / $limit);
    $c->stash->{url_for_page} = sub {
        my $page_number = shift; # Page number, 0 base
	$page_number--;

        my $new_offset = $page_number * $limit;

        my $query = $c->req->query_params;
        $query->{offset} = $new_offset;

	$c->uri_for('/moderation/open', $query);
    };

    $c->stash->{template} = 'moderation/open.tt';
    $c->stash->{edits   } = $edits;
}

=head2 conditions

Display a table of all edit types, and their relative conditions
for acceptance

=cut

sub conditions : Local
{
    my ($self, $c) = @_;
    
    my @qualities = (
        ModDefs::QUALITY_LOW,
        ModDefs::QUALITY_NORMAL,
        ModDefs::QUALITY_HIGH,
    );
    $c->stash->{quality_levels} = \@qualities;
    
    $c->stash->{qualities} = [ map {
        ModDefs::GetQualityText($_)
    } @qualities ];
    
    $c->stash->{quality_changes} = [
        map {
            my $level = Moderation::GetQualityChangeDefs($_);
            
            +{
                name            => $_ == 0 ? 'Lower Quality' : 'Raise Quality',
                voting_period   => $level->{duration},
                unanimous_votes => $level->{votes},
                expire_action   => ModDefs::GetExpireActionText($level->{expireaction}),
                is_autoedit     => $level->{autoedit},
            }
        }
        (0, 1)
    ];
    
    my %categories = ModDefs::GetModCategories();
    my @edits      = Moderation::GetEditTypes();
    
    $c->stash->{categories} = [
        map {
            my $cat = $_;
            
            +{
                title => ModDefs::GetModCategoryTitle($_),
                edits => [
                    sort { $a->{name} cmp $b->{name} }
                    grep {
                        my $name = $_->{name};
                        my %bad_names = (
                            'Edit Release Events (old version)' => 1,
                            'Add Track (old version)' => 1,
                            'Edit Artist Name' => 1,
                            'Edit Artist Sortname' => 1
                        );
                        not $bad_names{$name};
                    }
                    map {
                        my $edit_type = $_;
                        
                        my $hash = +{
                            map { $_ => Moderation::GetEditLevelDefs($_, $edit_type) }
                                @qualities
                        };
                        $hash->{name}     = Moderation::GetEditLevelDefs(ModDefs::QUALITY_NORMAL, $edit_type)->{name};
                        $hash->{criteria} = $categories{$edit_type}->{criteria};
                        
                        $hash;
                    }
                    grep { $categories{$_}->{category} == $cat } @edits ],
            };
        } (
            ModDefs::CAT_ARTIST,
            ModDefs::CAT_RELEASE,
            ModDefs::CAT_DEPENDS,
            ModDefs::CAT_NONE,
        )
    ];
}

1;
