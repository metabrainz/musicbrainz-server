package MusicBrainz::Server::Action::Form;

use strict;
use warnings;

use base qw/Catalyst::Action Class::Accessor/;

use Scalar::Util;
use UNIVERSAL::require;
use MRO::Compat;

__PACKAGE__->mk_accessors(qw/_attr_params/);

sub _create_form
{
    my ($self, $controller, $c) = @_;

    my $form_name;
    if ($form_name = $self->_attr_params->[0])
    {
        unless ($form_name =~ /^\+.*$/)
        {
            $form_name = $controller->config->{form_namespace} . '::' . $form_name;
        }
    }
    else
    {
        my ($root, $action) = ($c->action =~ m/(.*)\/(.*)/);
        $form_name = sprintf("%s::%s::%s",
            $controller->config->{form_namespace},
            ucfirst $root,
            join '', map { ucfirst $_ } split '_', $action
        );
    }

    $form_name->require
        or die "Could not find form $form_name";

    my $form = $form_name->new;
}

sub execute
{
    my $self = shift;
    my ($controller, $c) = @_;

    return $self->next::method(@_)
        unless exists $self->attributes->{ActionClass}
                   && ($self->attributes->{ActionClass}[0]
                       eq 'MusicBrainz::Server::Action::Form');

    my $form = $self->_create_form(@_);
    $form->context($c);

    $c->stash->{form} = $form;
    $controller->form($form);

    return $self->next::method(@_);
}

1;
