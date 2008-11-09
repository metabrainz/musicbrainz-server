package MusicBrainz::Server::Action::Form;

use strict;
use warnings;

use base qw/Catalyst::Action/;

use Scalar::Util;
use UNIVERSAL::require;

sub _create_form
{
    my ($self, $controller, $c) = @_;

    my ($root, $action) = ($c->action =~ m/(.*)\/(.*)/);
    my $form_name = sprintf("%s%s::%s",
        'MusicBrainz::Server::Form::',
        ucfirst $root,
        join '', map { ucfirst $_ } split '_', $action
    );

    $form_name->require
        or die "Could not find form $form_name";

    my $form = $form_name->new;
}

sub execute
{
    my $self = shift;
    my ($controller, $c) = @_;

    return $self->NEXT::execute(@_)
        unless exists $self->attributes->{ActionClass}
                   && ($self->attributes->{ActionClass}[0]
                       eq 'MusicBrainz::Server::Action::Form');

    my $form = $self->_create_form(@_);
    $form->context($c);

    $c->stash->{form} = $form;
    $controller->form($form);

    return $self->NEXT::execute(@_);
}

1;
