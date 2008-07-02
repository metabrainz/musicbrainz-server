package MusicBrainz::Server::Authentication::User;

use strict;
use warnings;

use base qw/Catalyst::Authentication::User/;

sub new
{
    my ($class, $user) = @_;
    bless { user => $user }, $class;
}

sub get
{
    my ($self, $what) = @_;

    if($what eq "password")
    {
        return $self->{user}->GetPassword;
    } elsif ($what eq "name") {
        return $self->{user}->GetName;
    }
}

sub get_object
{
    my $self = shift;
    $self->{user};
}

sub supported_features
{
    { session => 1 };
}

sub username
{
    shift->get('name');
}

1;
