package MusicBrainz::Server::Controller;
use Moose;
BEGIN { extends 'Catalyst::Controller'; }

use Carp;
use Data::Page;
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Constants qw( $AUTO_EDITOR_FLAG );
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation;
use Try::Tiny;

__PACKAGE__->config(
    form_namespace => 'MusicBrainz::Server::Form',
    paging_limit => 50,
);

sub not_found
{
    my ($self, $c) = @_;
    $c->response->status(404);
    $c->stash( template => $self->action_namespace . '/not_found.tt' );
    $c->detach;
}

sub invalid_mbid
{
    my ($self, $c, $id) = @_;
    $c->stash( message  => l("'{id}' is not a valid MusicBrainz ID", { id => $id }) );
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

=head2 submit_and_validate

Submit a form, and modify volatile privileges from form data. This
could mean changing the users temporary session privileges (disabling
auto-editing, for example).
=cut

sub submit_and_validate
{
    my ($self, $c) = @_;
    if($c->form_posted && $self->form->validate($c->req->body_params))
    {
        if ($self->form->isa('MusicBrainz::Server::Form'))
        {
            $self->form->check_volatile_prefs($c);
        }

        return 1;
    }
    else
    {
        return;
    }
}

sub _insert_edit {
    my ($self, $c, $form, %opts) = @_;

    my $privs   = $c->user->privileges;
    if ($c->user->is_auto_editor &&
        $form->field('as_auto_editor') &&
        !$form->field('as_auto_editor')->value) {
        $privs &= ~$AUTO_EDITOR_FLAG;
    }

    my $edit;
    try {
        $edit = $c->model('Edit')->create(
            editor_id => $c->user->id,
            privileges => $privs,
            %opts
        );
    }
    catch {
        if (ref($_) eq 'MusicBrainz::Server::Edit::Exceptions::NoChanges') {
            $c->stash( makes_no_changes => 1 );
        }
        else {
            use Data::Dumper;
            croak "The edit could not be created.\n" .
                "POST: " . Dumper($c->req->params) . "\n" .
                "Exception:" . Dumper($_);
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
        $c->flash->{message} = $edit->is_open
            ? l('Thank you, your edit has been entered into the edit queue for peer review.')
            : l('Thank you, your edit has been accepted and applied');
    }

    return $edit;
}

sub edit_action
{
    my ($self, $c, %opts) = @_;

    my %form_args = %{ $opts{form_args} || {}};
    $form_args{init_object} = $opts{item} if exists $opts{item};
    my $form = $c->form( form => $opts{form}, ctx => $c, %form_args );

    if ($c->form_posted && $form->submitted_and_valid($c->req->body_params)) {
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
            $opts{post_creation}->($edit, $form) if exists $opts{post_creation};
            $opts{on_creation}->($edit, $form) if $edit && exists $opts{on_creation};
        });

        # `post_creation` and `on_creation` often perform a redirection.
        # If they have called $c->res->redirect, $c->res->location will be a
        # true value, and we can detach early. `post_creation` and `on_creation`
        # can't do this, as $c->detach is implemented by throwing an exception,
        # which causes the above transaction to rollback.
        if ($c->res->location) {
            $c->detach;
        }

        return $edit;
    }
    elsif (!$c->form_posted && %{ $c->req->query_params }) {
        $form->process( params => $c->req->query_params );
        $form->clear_errors;
    }
}

sub _search_final_page
{
    my ($self, $loader, $limit, $page) = @_;

    my $min = 1;
    my $max = $page;

    while (($max - $min) > 1)
    {
        my $middle = $min + (($max - $min) >> 1);

        my ($data, $total) = $loader->($limit, ($middle - 1) * $limit);
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
    my $page = $c->request->query_params->{$prefix . "page"} || 1;
    $page = 1 if $page < 1;

    my $LIMIT = $opts{limit} || $self->{paging_limit};

    my ($data, $total) = $loader->($LIMIT, ($page - 1) * $LIMIT);
    my $pager = Data::Page->new;

    if ($page > 1 && scalar @$data == 0)
    {
        my $page = $self->_search_final_page ($loader, $LIMIT, $page);
        my $uri = $c->request->uri;
        my %params = $uri->query_form;

        $params{$prefix . "page"} = $page;
        $uri->query_form (\%params);

        $c->response->redirect ($uri);
        $c->detach;
    }

    $pager->entries_per_page($LIMIT);
    $pager->total_entries($total || 0);
    $pager->current_page($page);

    $c->stash( $prefix . "pager" => $pager );
    return $data;
}

sub redirect_back
{
    my ($self, $c, $ignore, $fallback) = @_;

    my $url = $c->request->referer;

    $url = $c->uri_for($fallback)
        if !$url || $url =~ qr{$ignore};

    $c->response->redirect($url);
}

sub error {
    my ($self, $c, %args) = @_;
    my $status = $args{status} || 500;
    $c->response->status($status);
    $c->stash(
        template => "main/$status.tt",
        message => $args{message}
    );
    $c->detach;
}

1;
