package MusicBrainz::Server::Controller;
use Moose; 
BEGIN { extends 'Catalyst::Controller'; }

use Data::Page;
use MusicBrainz::Server::Validation;

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

    $c->stash->{$self->{entity_name}} = $entity;
}

sub _load
{
    my ($self, $c, $gid) = @_;

    $c->detach('/error_404')
        unless MusicBrainz::Server::Validation::IsGUID($gid);

    return $c->model($self->{model})->get_by_gid($gid);
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

sub edit_action
{
    my ($self, $c, %opts) = @_;

    my %form_args;
    $form_args{item} = $opts{item} if exists $opts{item};
    my $form = $c->form( form => $opts{form}, %form_args );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params))
    {
        my $edit = $c->model('Edit')->create(
            edit_type => $opts{type},
            editor_id => $c->user->id,
            (map { $_->name => $_->value } $form->edit_fields),
            %{ $opts{edit_args} || {} },
        ) or die "Could not create edit";

        if ($form->does('MusicBrainz::Server::Form::Edit') &&
                $form->field('edit_note')->value) {
            $c->model('EditNote')->add_note($edit->id, {
                text      => $form->field('edit_note')->value,
                editor_id => $c->user->id,
            })
        }

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
