package MusicBrainz::Server::Controller;
use Moose;
BEGIN { extends 'Catalyst::Controller'; }

use Carp;
use Data::Page;
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Constants qw( $UNTRUSTED_FLAG $LIMIT_FOR_EDIT_LISTING );
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation qw( is_positive_integer );
use Try::Tiny;

__PACKAGE__->config(
    form_namespace => 'MusicBrainz::Server::Form',
    paging_limit => 100,
);

sub not_found : Private
{
    my ($self, $c) = @_;
    $c->response->status(404);
    $c->stash(
        current_view    => 'Node',
        component_path  => 'entity/NotFound',
        component_props => {namespace => $self->action_namespace},
    );
    $c->detach;
}

sub invalid_mbid
{
    my ($self, $c, $id) = @_;
    $c->stash( message  => l(q('{id}' is not a valid MusicBrainz ID), { id => $id }) );
    $c->detach('/error_400');
}

sub create_action
{
    my $self = shift;
    my %args = @_;

    if (exists $args{attributes}{'Form'})
    {
        $args{_attr_params} = delete $args{attributes}{'Form'};
        push @{ $args{attributes}{ActionClass} },
            'MusicBrainz::Server::Action::Form';
    }

    $self->SUPER::create_action(%args);
}

sub _insert_edit {
    my ($self, $c, $form, %opts) = @_;

    if (!$c->user->has_confirmed_email_address) {
        $c->detach('/error_401');
    }

    my $privs = $c->user->privileges;
    if ($form->field('make_votable') &&
        $form->field('make_votable')->value) {
        $privs |= $UNTRUSTED_FLAG;
    }

    my $edit;
    try {
        $edit = $c->model('Edit')->create(
            editor => $c->user,
            privileges => $privs,
            %opts
        );
    } catch {
        if (ref($_) eq 'MusicBrainz::Server::Edit::Exceptions::NoChanges') {
            $c->stash( makes_no_changes => 1 );
        } elsif (ref($_) eq 'MusicBrainz::Server::Edit::Exceptions::NeedsDisambiguation') {
            $c->stash(needs_disambiguation => 1);
        } elsif (ref($_) eq 'MusicBrainz::Server::Edit::Exceptions::DuplicateViolation') {
            $c->stash(duplicate_violation => 1);
        } else {
            croak 'The edit could not be created. Exception (' . (ref ne '' ? ref : 'string') . '): ' . $_;
        }
    };

    if (defined $edit &&
            $form->does('MusicBrainz::Server::Form::Role::Edit') &&
            $form->field('edit_note')->value) {
        $c->model('EditNote')->add_note($edit->id, {
            text      => $form->field('edit_note')->value,
            editor_id => $c->user->id,
        });
    }

    if (defined $edit)
    {
      if (not defined $c->stash->{edit_ids}) {
        $c->stash->{edit_ids} = [ $edit->id ];
        $c->stash->{num_open_edits} = $edit->is_open;
      } else {
        push(@{$c->stash->{edit_ids}}, $edit->id );
        $c->stash->{num_open_edits}++ if $edit->is_open;
      }

      my %args = ( num_edits => scalar(@{$c->stash->{edit_ids}}),
                   num_open_edits => $c->stash->{num_open_edits} );
      my $first_edit_id = $c->stash->{edit_ids}->[0];
      my @edit_ids = @{$c->stash->{edit_ids}};
      $args{edit_ids} = '#' . join(', #', @edit_ids[0.. ($#edit_ids > 2 ? 2 : $#edit_ids)]) . ($#edit_ids>2?', ...':'');
      $args{edit_url} =
        (($args{num_edits} == 1)
         ? $c->uri_for_action('/edit/show', [ $first_edit_id ])
         : $c->uri_for_action('/edit/search',
                              { 'conditions.0.field'=>'id',
                                'conditions.0.operator'=>'BETWEEN',
                                'conditions.0.args.0'=>$first_edit_id,
                                'conditions.0.args.1'=>$c->stash->{edit_ids}->[-1]
                              }));

      if ($args{num_open_edits} == 0) {
        # All autoedits
        $c->flash->{message} =
          ln('Thank you, your {edit_url|edit} ({edit_ids}) has been automatically accepted and applied.',
             'Thank you, your {num_edits} {edit_url|edits} ({edit_ids}) have been automatically accepted and applied.',
             $args{num_edits}, \%args);
      } elsif ($args{num_open_edits} == $args{num_edits}) {
        # All open edits
        $c->flash->{message} =
          ln('Thank you, your {edit_url|edit} ({edit_ids}) has been entered into the edit queue for peer review.',
             'Thank you, your {num_edits} {edit_url|edits} ({edit_ids}) have been entered into the edit queue for peer review.',
             $args{num_edits}, \%args);
      } else {
        # Mixture of both
        # Even though the singular case is impossible (since 1 edit must be either an autoedit or open),
        # it is included since gettext uses the singular case as a key.
        $c->flash->{message} =
          ln('Thank you, your {edit_url|edit} ({edit_ids}) has been entered, with {num_open_edits} in the edit queue for peer review, and the rest automatically accepted and applied.',
             'Thank you, your {num_edits} {edit_url|edits} ({edit_ids}) have been entered, with {num_open_edits} in the edit queue for peer review, and the rest automatically accepted and applied.',
             $args{num_edits}, \%args);
      }
    }

    return $edit;
}

sub edit_action
{
    my ($self, $c, %opts) = @_;

    if (!$c->user->has_confirmed_email_address) {
        $c->detach('/error_401');
    }

    my %form_args = %{ $opts{form_args} || {}};
    $form_args{init_object} = $opts{item} if exists $opts{item};
    my $form = $c->form( form => $opts{form}, ctx => $c, %form_args );

    $opts{pre_validation}->($form) if exists $opts{pre_validation};

    if ($c->form_posted_and_valid($form, $c->req->body_params)) {
        if (exists $opts{pre_creation} && !$opts{pre_creation}->($form)) {
            $c->stash->{component_props}{form} = $form->TO_JSON;
            return;
        }

        my @options = (map { $_->name => $_->value } $form->edit_fields);
        my %extra   = %{ $opts{edit_args} || {} };

        my $edit;
        $c->model('MB')->with_transaction(sub {
            $edit = $self->_insert_edit(
                $c, $form,
                edit_type => $opts{type},
                @options,
                %extra
            );

            # the on_creation hook is only called when an edit was entered.
            # the post_creation hook is always called.
            my $has_post_creation_changes = 0;
            if (exists $opts{post_creation}) {
                $has_post_creation_changes =
                    $opts{post_creation}->($edit, $form);
            }

            if ($edit && exists $opts{on_creation}) {
                $opts{on_creation}->($edit, $form);
            }

            if ($has_post_creation_changes && $c->stash->{makes_no_changes}) {
                $c->stash( makes_no_changes => 0 );
            }
        });

        $c->stash->{component_props}{form} = $form->TO_JSON;

        if ($opts{redirect} && !$opts{no_redirect} &&
                ($edit || !$c->stash->{makes_no_changes}) &&
                !$c->stash->{needs_disambiguation} &&
                !$c->stash->{duplicate_violation}) {
            $opts{redirect}->();
            $c->detach;
        }

        return $edit;
    }
    elsif (!$c->form_posted && %{ $c->req->query_params }) {
        my $merged = { ( %{$form->fif}, %{$c->req->query_params} ) };
        $form->process( params => $merged );
        $form->clear_errors;
    }
    $c->stash->{component_props}{form} = $form->TO_JSON;
}

sub _search_final_page
{
    my ($self, $loader, $limit, $page) = @_;

    my $min = 1;
    my $max = $page;

    while (($max - $min) > 1)
    {
        my $middle = $min + (($max - $min) >> 1);

        my ($data, undef) = $loader->($limit, ($middle - 1) * $limit);
        if (scalar @$data > 0)
        {
            $min = $middle;
        }
        else
        {
            $max = $middle;
        }
    }

    return $min;
}


sub _load_paged
{
    my ($self, $c, $loader, %opts) = @_;

    my $prefix = $opts{prefix} || '';
    my $page = $c->request->query_params->{$prefix . 'page'};
    $page = 1 unless is_positive_integer($page);

    my $LIMIT = $opts{limit} || $self->{paging_limit};

    my ($data, $total) = $loader->($LIMIT, ($page - 1) * $LIMIT);
    my $pager = Data::Page->new;

    if ($page > 1 && scalar @$data == 0)
    {
        my $page = $self->_search_final_page($loader, $LIMIT, $page);
        $c->response->redirect($c->request->uri_with({ ($prefix . 'page') => $page }));
        $c->detach;
    }

    $pager->entries_per_page($LIMIT);
    $pager->total_entries($total || 0);
    $pager->current_page($page);

    $c->stash( $prefix . 'pager' => $pager,
               edit_count_limit => $LIMIT_FOR_EDIT_LISTING );
    return $data;
}

sub error {
    my ($self, $c, %args) = @_;
    my $status = $args{status} || 500;
    $c->response->status($status);
    $c->stash(
        current_view => 'Node',
        component_path => "main/error/Error$status",
        component_props => {
            message => $args{message}
        }
    );
    $c->detach;
}

sub ws1_gone : Chained('/') PathPart('ws/1') {
    my ($self, $c) = @_;

    $c->res->content_type('text/plain; charset=utf-8');
    $c->res->body('https://blog.metabrainz.org/2018/02/01/web-service-ver-1-0-ws-1-will-be-removed-in-6-months/');
    $c->res->status(410);
}

1;
