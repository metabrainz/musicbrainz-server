package MusicBrainz::Server::Controller::Edit;
use Moose;
use Moose::Util qw( does_role );
use Try::Tiny;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use Data::Page;
use DBDefs;
use MusicBrainz::Server::EditRegistry;
use MusicBrainz::Server::Edit::Utils qw( status_names );
use MusicBrainz::Server::Constants qw( :quality );
use MusicBrainz::Server::Validation qw( is_database_row_id );
use MusicBrainz::Server::EditSearch::Query;
use MusicBrainz::Server::Data::Utils qw( type_to_model load_everything_for_edits );
use MusicBrainz::Server::Translation qw( N_l );
use List::UtilsBy qw( sort_by );

use aliased 'MusicBrainz::Server::EditRegistry';

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'Edit',
    entity_name => 'edit',
};

__PACKAGE__->config(
    paging_limit => 50,
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
    return unless is_database_row_id($edit_id);
    return $c->model('Edit')->get_by_id($edit_id);
}

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;
    my $edit = $c->stash->{edit};

    load_everything_for_edits($c, [ $edit ]);
    $c->form(add_edit_note => 'EditNote');

    $c->stash->{template} = 'edit/index.tt';
}

sub data : Chained('load') RequireAuth
{
    my ($self, $c) = @_;

    my $edit = $c->stash->{edit};

    my $accept = $c->req->header('Accept');
    if ($accept eq 'application/json') {
        $c->res->content_type('application/json; charset=utf-8');
        $c->res->body($c->json_utf8->encode({
            data => $c->json->decode($edit->raw_data),
            status => $edit->status,
            type => $edit->edit_type,
        }));
        return;
    }

    my $related = $c->model('Edit')->get_related_entities($edit);
    my %entities;
    while (my ($type, $ids) = each %$related) {
        $entities{$type} = $c->model(type_to_model($type))->get_by_ids(@$ids) if @$ids;
    }

    $c->stash( related_entities => \%entities,
               template => 'edit/data.tt' );
}

sub enter_votes : Local RequireAuth DenyWhenReadonly
{
    my ($self, $c) = @_;

    my $form = $c->form(vote_form => 'Vote');
    if ($c->form_posted_and_valid($form)) {
        my @submissions = @{ $form->field('vote')->value };
        my @votes = grep { defined($_->{vote}) } @submissions;
        unless ($c->user->is_editing_enabled || scalar @votes == 0) {
            $c->stash(
                current_view => 'Node',
                component_path => 'edit/CannotVote',
            );
            return;
        }
        $c->model('Edit')->insert_votes_and_notes(
            $c->user,
            votes => [ @votes ],
            notes => [ grep { defined($_->{edit_note}) } @submissions ]
        );
    }

    my $redir = $c->req->params->{url} || $c->uri_for_action('/edit/open');
    $c->response->redirect($redir);
    $c->detach;
}

sub approve : Chained('load') RequireAuth(auto_editor) RequireAuth(editing_enabled) DenyWhenReadonly
{
    my ($self, $c) = @_;

    $c->model('MB')->with_transaction(sub {
        my $edit = $c->model('Edit')->get_by_id_and_lock($c->stash->{edit}->id);
        $c->model('Vote')->load_for_edits($edit);

        if (!$edit->editor_may_approve($c->user)) {
            $c->stash(
                current_view => 'Node',
                component_path => 'edit/CannotApproveEdit',
                component_props => {edit => $edit},
            );
            return;
        }
        else {
            if ($edit->approval_requires_comment($c->user)) {
                $c->model('EditNote')->load_for_edits($edit);
                my $left_note;
                for my $note (@{ $edit->edit_notes }) {
                    next if $note->editor_id != $c->user->id;
                    $left_note = 1;
                    last;
                }

                unless ($left_note) {
                    $c->stash(
                        current_view => 'Node',
                        component_path => 'edit/NoteIsRequired',
                        component_props => {edit => $edit},
                    );
                    return;
                };
            }

            $c->model('Edit')->approve($edit, $c->user);

            $c->redirect_back(
                fallback => $c->uri_for_action('/edit/show', [ $edit->id ]),
            );
        }
    });
}

sub cancel : Chained('load') RequireAuth DenyWhenReadonly
{
    my ($self, $c) = @_;
    my $edit = $c->stash->{edit};
    if (!$edit->editor_may_cancel($c->user)) {
        $c->stash(
            current_view => 'Node',
            component_path => 'edit/CannotCancelEdit',
            component_props => {edit => $edit},
        );
        $c->detach;
    }

    $c->model('Edit')->load_all($edit);

    my $form = $c->form(form => 'Confirm');
    if ($c->form_posted_and_valid($form)) {
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

        $c->response->redirect($c->stash->{cancel_redirect} || $c->req->query_params->{returnto} || $c->uri_for_action('/edit/show', [ $edit->id ]));
        $c->detach;
    }
}

=head2 open

Show a list of open moderations

=cut

sub open : Local
{
    my ($self, $c) = @_;

    my $edits = $self->_load_paged($c, sub {
         $c->model('Edit')->find_open_for_editor($c->user->id, shift, shift);
    });

    $c->stash( edits => $edits ); # stash early in case an ISE occurs

    load_everything_for_edits($c, $edits);
    $c->form(add_edit_note => 'EditNote');
}

sub search : Path('/search/edits')
{
    my ($self, $c) = @_;
    my $coll = $c->get_collator();
    my %grouped = MusicBrainz::Server::EditRegistry->grouped_by_name;
    $c->stash(
        edit_types => [
            map [
                join(',', map { $_->edit_type } @{ $grouped{$_} }) => $_
            ], sort_by { $coll->getSortKey($_) } keys %grouped
        ],
        status => status_names(),
        quality => [ [$QUALITY_LOW => N_l('Low')], [$QUALITY_NORMAL => N_l('Normal')], [$QUALITY_HIGH => N_l('High')], [$QUALITY_UNKNOWN => N_l('Default')] ],
        languages => [ grep { $_->frequency > 0 } $c->model('Language')->get_all ],
        countries => [ $c->model('CountryArea')->get_all ],
        relationship_type => [ $c->model('LinkType')->get_full_tree ]
    );
    return unless %{ $c->req->query_params };

    my $query = MusicBrainz::Server::EditSearch::Query->new_from_user_input($c->req->query_params, $c->user);
    $c->stash( query => $query );

    if ($query->valid && !$c->req->query_params->{'form_only'}) {
        my $edits;
        my $timed_out = 0;

        try {
            $edits = $self->_load_paged($c, sub {
                return $c->model('Edit')->run_query($query, shift, shift);
            });
        } catch {
            unless (blessed $_ && does_role($_, 'MusicBrainz::Server::Exceptions::Role::Timeout')) {
                die $_; # rethrow
            }
            $timed_out = 1;
        };
        if ($timed_out) {
            $c->stash( timed_out => 1 );
            return;
        }

        $c->stash(
            edits => $edits, # stash early in case an ISE occurs
            template => 'edit/search_results.tt',
        );

        load_everything_for_edits($c, $edits);
        $c->form(add_edit_note => 'EditNote');
    }
}

sub subscribed : Local RequireAuth {
    my ($self, $c) = @_;

    my $only_open = 0;
    if (($c->req->query_params->{open} // '') eq '1') {
        $only_open = 1;
    }

    my $edits = $self->_load_paged($c, sub {
        $c->model('Edit')->subscribed_entity_edits($c->user->id, $only_open, shift, shift);
    });

    $c->stash(
        edits => $edits, # stash early in case an ISE occurs
        template => 'edit/subscribed.tt',
    );

    load_everything_for_edits($c, $edits);
}

sub subscribed_editors : Local RequireAuth {
    my ($self, $c) = @_;

    my $only_open = 0;
    if (($c->req->query_params->{open} // '') eq '1') {
        $only_open = 1;
    }

    my $edits = $self->_load_paged($c, sub {
        $c->model('Edit')->subscribed_editor_edits($c->user->id, $only_open, shift, shift);
    });

    $c->stash(
        edits => $edits, # stash early in case an ISE occurs
        template => 'edit/subscribed-editors.tt',
    );

    load_everything_for_edits($c, $edits);
}

sub notes_received : Path('/edit/notes-received') RequireAuth {
    my ($self, $c) = @_;

    # Log when the editor loaded the page, so that we know when to notify them
    # again about new edits (see Data::EditNote::add_note).
    my $store = $c->model('MB')->context->store;
    my $notes_viewed_key = 'edit_notes_received_last_viewed:' . $c->user->name;
    $store->set($notes_viewed_key, time);
    # Expire the notification in 30 days.
    $store->expire($notes_viewed_key, 60 * 60 * 24 * 30);

    my $edit_notes = $self->_load_paged($c, sub {
        $c->model('EditNote')->find_by_recipient($c->user->id, shift, shift);
    });

    $c->model('Editor')->load(@$edit_notes);
    $c->model('Edit')->load_for_edit_notes(@$edit_notes);
    $c->model('Vote')->load_for_edits(map { $_->edit } @$edit_notes);

    $c->stash(
        edit_notes => $edit_notes,
        template => 'edit/notes-received.tt',
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

    my $class;
    $class = EditRegistry->class_from_type($edit_type)
        if is_database_row_id($edit_type);
    $class or $c->detach('/error_404');

    my $id = ('Edit Type/' . $class->edit_name) =~ tr/ /_/r;

    my $version = $c->model('WikiDocIndex')->get_page_version($id);
    my $page = $c->model('WikiDoc')->get_page($id, $version);

    $c->stash(
        edit_type => $class,
        template => 'doc/edit_type.tt',
        page => $page
    );
}

1;
