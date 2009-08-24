package MusicBrainz::Server::Controller::Edit;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use Data::Page;
use DBDefs;
use MusicBrainz::Server::Vote;

__PACKAGE__->config(
    entity_name => 'edit',
);

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

sub base : Chained('/') PathPart('edit') CaptureArgs(0) { }

sub _load
{
    my ($self, $c, $edit_id) = @_;
    return $c->model('Edit')->get_by_id($edit_id);
}

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;
    my $edit = $c->stash->{edit};

    $c->model('Edit')->load_all($edit);
    $c->model('Vote')->load_for_edits($edit);
    $c->model('Editor')->load($edit, @{ $edit->votes });

    $c->stash->{template} = 'edit/index.tt';
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

sub enter_votes : Local RequireAuth
{
    my ($self, $c) = @_;

    my $form = $c->form(vote_form => 'Vote');
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my @votes = @{ $form->field('vote')->value };
        $c->model('Vote')->enter_votes($c->user->id, @votes);
    } else {
        die "Invalid form?";
    }

    my $redir = $c->req->params->{url} || $c->uri_for_action('/edit/open_edits');
    $c->response->redirect($redir);
    $c->detach;
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
    
    my $page = $c->req->{query_params}->{page} || 1;

    my ($edits, $pager)= $c->model('Moderation')->list_open($page);

    $c->stash->{pager} = $pager;
    $c->stash->{edits} = $edits;
}

=head2 for_type

Show all edits for a certain entity

=cut

sub for_type : Path('entity') Args(2)
{
    my ($self, $c, $type, $mbid) = @_;

    my $page = $c->req->{query_params}->{page} || 1;
    
    my $entity = $c->model(ucfirst $type)->load($mbid);
    my ($edits, $pager) = $c->model('Moderation')->edits_for_entity($entity, $page);
    
    $c->stash->{edits}  = $edits;
    $c->stash->{pager}  = $pager;
    $c->stash->{entity} = $entity;
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
