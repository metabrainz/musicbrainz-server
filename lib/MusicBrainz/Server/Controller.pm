package MusicBrainz::Server::Controller;

use strict;
use warnings;

use base qw/Catalyst::Controller Class::Accessor/;

use MusicBrainz::Server::Validation;

__PACKAGE__->mk_accessors(qw/ entity form /);
__PACKAGE__->config(
    form_namespace => 'MusicBrainz::Server::Form'
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

    unless (MusicBrainz::Server::Validation::IsGUID($gid))
    {
        $c->detach('/error_404');
    }

    my $entity = $c->model($self->{model})->get_by_gid($gid);
    unless (defined($entity))
    {
        $c->detach('/error_404');
    }

    $c->stash->{$self->{entity_name}} = $entity;
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

1;
