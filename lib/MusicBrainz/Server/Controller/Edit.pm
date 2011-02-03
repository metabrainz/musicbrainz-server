package MusicBrainz::Server::Controller::Edit;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use Data::Page;
use DBDefs;
use MusicBrainz::Server::Types qw( $STATUS_OPEN );
use MusicBrainz::Server::Validation qw( is_positive_integer );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'Edit',
    entity_name => 'edit',
};

__PACKAGE__->config(
    paging_limit => 25,
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
    return unless is_positive_integer($edit_id);
    return $c->model('Edit')->get_by_id($edit_id);
}

sub show : Chained('load') PathPart('') RequireAuth
{
    my ($self, $c) = @_;
    my $edit = $c->stash->{edit};

    $c->model('Edit')->load_all($edit);
    $c->model('Vote')->load_for_edits($edit);
    $c->model('EditNote')->load_for_edits($edit);
    $c->model('Editor')->load($edit, @{ $edit->votes }, @{ $edit->edit_notes });
    $c->form(add_edit_note => 'EditNote');

    $c->stash->{template} = 'edit/index.tt';
}

sub enter_votes : Local RequireAuth
{
    my ($self, $c) = @_;

    my $form = $c->form(vote_form => 'Vote');
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my @submissions = @{ $form->field('vote')->value };
        $c->model('Edit')->insert_votes_and_notes(
            $c->user->id,
            votes => [ grep { defined($_->{vote}) } @submissions ],
            notes => [ grep { defined($_->{edit_note}) } @submissions ]
        );
    }

    my $redir = $c->req->params->{url} || $c->uri_for_action('/edit/open_edits');
    $c->response->redirect($redir);
    $c->detach;
}

sub approve : Chained('load') RequireAuth(auto_editor)
{
    my ($self, $c) = @_;

    my $edit = $c->stash->{edit};
    if (!$edit->can_approve($c->user)) {
        $c->stash( template => 'edit/cannot_approve.tt' );
        $c->detach;
    }

    if($edit->no_votes > 0) {
        $c->model('EditNote')->load_for_edits($edit);
        my $left_note;
        for my $note (@{ $edit->edit_notes }) {
            next if $note->editor_id != $c->user->id;
            $left_note = 1;
            last;
        }

        unless($left_note) {
            $c->stash( template => 'edit/require_note.tt' );
            $c->detach;
        };
    }

    $c->model('Edit')->approve($edit, $c->user->id);
    $c->response->redirect($c->req->query_params->{url} || $c->uri_for_action('/edit/show', [ $edit->id ]));
}

sub cancel : Chained('load') RequireAuth
{
    my ($self, $c) = @_;

    my $edit = $c->stash->{edit};
    if (!$edit->can_cancel($c->user)) {
        $c->stash( template => 'edit/cannot_cancel.tt' );
        $c->detach;
    }
    $c->model('Edit')->cancel($edit);

    $c->response->redirect($c->req->query_params->{url} || $c->uri_for_action('/edit/show', [ $edit->id ]));
    $c->detach;
}

=head2 open

Show a list of open moderations

=cut

sub open : Local RequireAuth
{
    my ($self, $c) = @_;

    my $edits = $self->_load_paged($c, sub {
         $c->model('Edit')->find({ status => $STATUS_OPEN }, shift, shift);
    });

    $c->model('Edit')->load_all(@$edits);
    $c->model('Vote')->load_for_edits(@$edits);
    $c->model('EditNote')->load_for_edits(@$edits);
    $c->model('Editor')->load(map { ($_, @{ $_->votes, $_->edit_notes }) } @$edits);
    $c->form(add_edit_note => 'EditNote');

    $c->stash( edits => $edits );
}

sub search : Path('/search/edits') RequireAuth
{
    my ($self, $c) = @_;

    my $form = $c->form( form => 'Search::Edits' );
    if ($form->submitted_and_valid($c->req->query_params)) {
        my @types = @{ $form->field('type')->value };

        my $edits = $self->_load_paged($c, sub {
            return $c->model('Edit')->find({
                type   => [ map { split /,/ } @types ],
                status => $form->field('status')->value,
            }, shift, shift);
        });

        $c->model('Edit')->load_all(@$edits);
        $c->model('Vote')->load_for_edits(@$edits);
        $c->model('EditNote')->load_for_edits(@$edits);
        $c->model('Editor')->load(map { ($_, @{ $_->votes, $_->edit_notes }) } @$edits);
        $c->form(add_edit_note => 'EditNote');

        $c->stash(
            edits    => $edits,
            template => 'edit/search_results.tt'
        );
    }
}

sub subscribed : Local RequireAuth
{
    my ($self, $c) = @_;
    my $edits = $self->_load_paged($c, sub {
        $c->model('Edit')->subscribed_entity_edits($c->user->id, shift, shift);
    });
    $c->model('Edit')->load_all(@$edits);
    $c->model('Editor')->load(@$edits);
    $c->model('Vote')->load_for_edits(@$edits);
    $c->model('EditNote')->load_for_edits(@$edits);

    $c->stash(
        edits    => $edits,
        template => 'edit/search_results.tt'
    );
}

=head2 conditions

Display a table of all edit types, and their relative conditions
for acceptance

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

=cut

1;
