package MusicBrainz::Server::Controller::Edit;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use Data::Page;
use DBDefs;
use MusicBrainz::Server::EditRegistry;
use MusicBrainz::Server::Edit::Utils qw( status_names );
use MusicBrainz::Server::Constants qw( $STATUS_OPEN :quality );
use MusicBrainz::Server::Validation qw( is_positive_integer );
use MusicBrainz::Server::EditSearch::Query;
use MusicBrainz::Server::Translation qw( N_l );

use aliased 'MusicBrainz::Server::EditRegistry';

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

sub enter_votes : Local RequireAuth DenyWhenReadonly
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

    my $redir = $c->req->params->{url} || $c->uri_for_action('/edit/open');
    $c->response->redirect($redir);
    $c->detach;
}

sub approve : Chained('load') RequireAuth(auto_editor) DenyWhenReadonly
{
    my ($self, $c) = @_;

    $c->model('MB')->with_transaction(sub {
        my $edit = $c->model('Edit')->get_by_id_and_lock($c->stash->{edit}->id);
        $c->model('Vote')->load_for_edits($edit);

        if (!$edit->can_approve($c->user)) {
            $c->stash( template => 'edit/cannot_approve.tt' );
            return;
        }
        else {
            if($edit->approval_requires_comment($c->user)) {
                $c->model('EditNote')->load_for_edits($edit);
                my $left_note;
                for my $note (@{ $edit->edit_notes }) {
                    next if $note->editor_id != $c->user->id;
                    $left_note = 1;
                    last;
                }

                unless($left_note) {
                    $c->stash( template => 'edit/require_note.tt' );
                    return;
                };
            }

            $c->model('Edit')->approve($edit, $c->user->id);
            $c->response->redirect(
                $c->req->query_params->{url} || $c->uri_for_action('/edit/show', [ $edit->id ]));
        }
    });
}

sub cancel : Chained('load') RequireAuth DenyWhenReadonly
{
    my ($self, $c) = @_;
    my $edit = $c->stash->{edit};
    if (!$edit->can_cancel($c->user)) {
        $c->stash( template => 'edit/cannot_cancel.tt' );
        $c->detach;
    }

    $c->model('Edit')->load_all($edit);

    my $form = $c->form(form => 'Confirm');
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        $c->model('MB')->with_transaction(sub {
            $c->model('Edit')->cancel($edit);

            if (my $edit_note = $form->field('edit_note')->value) {
                $c->model('EditNote')->add_note(
                    $edit->id,
                    {
                        editor_id => $c->user->id,
                        text      => $edit_note
                    }
                );
            }
        });

        $c->response->redirect($c->req->query_params->{url} || $c->uri_for_action('/edit/show', [ $edit->id ]));
        $c->detach;
    }
}

=head2 open

Show a list of open moderations

=cut

sub open : Local RequireAuth
{
    my ($self, $c) = @_;

    my $edits = $self->_load_paged($c, sub {
         $c->model('Edit')->find_open_for_editor($c->user->id, shift, shift);
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
    my %grouped = MusicBrainz::Server::EditRegistry->grouped_by_name;
    $c->stash(
        edit_types => [
            map [
                join(',', map { $_->edit_type } @{ $grouped{$_} }) => $_
            ], sort keys %grouped
        ],
        status => status_names(),
        quality => [ [$QUALITY_LOW => N_l('Low')], [$QUALITY_NORMAL => N_l('Normal')], [$QUALITY_HIGH => N_l('High')], [$QUALITY_UNKNOWN => N_l('Default')] ],
        languages => [ grep { $_->frequency > 0 } $c->model('Language')->get_all ],
        countries => [ $c->model('CountryArea')->get_all ],
        relationship_type => [ $c->model('LinkType')->get_full_tree ]
    );
    return unless %{ $c->req->query_params };

    my $query = MusicBrainz::Server::EditSearch::Query->new_from_user_input($c->req->query_params);
    $c->stash( query => $query );

    if ($query->valid) {
        my $edits = $self->_load_paged($c, sub {
            return $c->model('Edit')->run_query($query, shift, shift);
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
    $c->model('Vote')->load_for_edits(@$edits);
    $c->model('EditNote')->load_for_edits(@$edits);
    $c->model('Editor')->load(map { ($_, @{ $_->votes, $_->edit_notes }) } @$edits);

    $c->stash(
        edits    => $edits,
        template => 'edit/subscribed.tt'
    );
}

sub subscribed_editors : Local RequireAuth
{
    my ($self, $c) = @_;
    my $edits = $self->_load_paged($c, sub {
        $c->model('Edit')->subscribed_editor_edits($c->user->id, shift, shift);
    });
    $c->model('Edit')->load_all(@$edits);
    $c->model('Vote')->load_for_edits(@$edits);
    $c->model('EditNote')->load_for_edits(@$edits);
    $c->model('Editor')->load(map { ($_, @{ $_->votes, $_->edit_notes }) } @$edits);

    $c->stash(
        edits    => $edits,
        template => 'edit/subscribed-editors.tt'
    );
}

=head2 conditions

Display a table of all edit types, and their relative conditions
for acceptance

=cut

sub edit_types : Path('/doc/Edit_Types')
{
    my ($self, $c) = @_;

    my %by_category;
    for my $class (EditRegistry->get_all_classes) {
        $by_category{$class->edit_category} ||= [];
        push @{ $by_category{$class->edit_category} }, $class;
    }

    for my $category (keys %by_category) {
        $by_category{$category} = [
            sort { $a->l_edit_name cmp $b->l_edit_name }
                @{ $by_category{$category} }
            ];
    }

    $c->stash(
        by_category => \%by_category,
        template => 'doc/edit_types.tt'
    );
}

sub edit_type : Path('/doc/Edit_Types') Args(1) {
    my ($self, $c, $edit_type) = @_;

    my $class = EditRegistry->class_from_type($edit_type);
    my $id = 'Edit Type/$class->edit_name';
    $id =~ s/ /_/g;

    my $version = $c->model('WikiDocIndex')->get_page_version($id);
    my $page = $c->model('WikiDoc')->get_page($id, $version);

    $c->detach('/error_404') unless $class;

    $c->stash(
        edit_type => $class,
        template => 'doc/edit_type.tt',
        page => $page
    );
}

1;
