package MusicBrainz::Server::Model::Base;

use strict;
use warnings;

use base 'Catalyst::Model';

use MusicBrainz;

sub new
{
    my $self = shift;
    $self = $self->NEXT::new(@_);

    $self->{mb} = new MusicBrainz;
    $self->{mb}->Login();

    return $self;
}

sub dbh
{
    my $self = shift;
    $self->{mb}->{DBH};
}

1;
