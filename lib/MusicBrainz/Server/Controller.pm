package MusicBrainz::Server::Controller;
use Moose;
BEGIN { extends 'Catalyst::Controller'; }

use Data::Page;
use MusicBrainz::Server::Types qw( $AUTO_EDITOR_FLAG );
use MusicBrainz::Server::Validation;
use Scalar::Util qw( looks_like_number );

__PACKAGE__->config(
    form_namespace => 'MusicBrainz::Server::Form',
    paging_limit => 50,
);

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

sub load : Chained('base') PathPart('') CaptureArgs(1)
{
    my ($self, $c, $gid) = @_;

    my $entity = $self->_load($c, $gid)
        or $c->detach('/error_404');

    $c->stash(
        # First stash is more convenient for the actual controller
        # Second is useful to roles or other places that need introspection
        $self->{entity_name} => $entity,
        entity               => $entity
    );
}

sub _load
{
    my ($self, $c, $id) = @_;

    if (MusicBrainz::Server::Validation::IsGUID($id)) {
        return $c->model($self->{model})->get_by_gid($id);
    }
    elsif (looks_like_number($id)) {
        my $gid = $self->_row_id_to_gid($c, $id) or $c->detach('/error_404');
        $c->response->redirect($c->uri_for_action($c->action, [ $gid ]));
        $c->detach;
    }
    else {
        $c->detach('/error_404');
    }
}

sub _row_id_to_gid {
    my ($self, $c, $row_id) = @_;

    my $entity = $c->model($self->{model})->get_by_id($row_id) or return;
    return $entity->gid;
}

=head2 submit_and_validate

Submit a form, and modify volatile privileges from form data. This
could mean changing the users temporary session privileges (disabling
auto-editing, for example).
=cut

sub submit_and_validate
{
    my ($self, $c) = @_;
    if($c->form_posted && $self->form->validate($c->req->params))
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
    if ($c->user->is_auto_editor && !$form->field('as_auto_editor')->value) {
        $privs &= ~$AUTO_EDITOR_FLAG;
    }

    my $edit = $c->model('Edit')->create(
        editor_id => $c->user->id,
        privileges => $privs,
        %opts
    );

    if (!$edit) {
        use Data::Dumper;
        die "Could not create edit\n" . Dumper(\%opts);
    }

    if (defined $edit &&
            $form->does('MusicBrainz::Server::Form::Role::Edit') &&
            $form->field('edit_note')->value) {
        $c->model('EditNote')->add_note($edit->id, {
            text      => $form->field('edit_note')->value,
            editor_id => $c->user->id,
        });
    }

    return $edit;
}

sub edit_action
{
    my ($self, $c, %opts) = @_;

    my %form_args = %{ $opts{form_args} || {}};
    $form_args{init_object} = $opts{item} if exists $opts{item};
    my $form = $c->form( form => $opts{form}, %form_args );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params))
    {
        my @options = (map { $_->name => $_->value } $form->edit_fields);
        my %extra   = %{ $opts{edit_args} || {} };

        my $edit = $self->_insert_edit($c, $form,
            edit_type => $opts{type},
            @options,
            %extra
        );

        $opts{on_creation}->($edit) if exists $opts{on_creation};
    }
}

sub _load_paged
{
    my ($self, $c, $loader) = @_;

    my $page = $c->request->query_params->{page} || 1;
    $page = 1 if $page < 1;

    my $LIMIT = $self->{paging_limit};

    my ($data, $total) = $loader->($LIMIT, ($page - 1) * $LIMIT);
    my $pager = Data::Page->new;
    $pager->entries_per_page($LIMIT);
    $pager->total_entries($total);
    $pager->current_page($page);

    $c->stash( pager => $pager );
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

1;
