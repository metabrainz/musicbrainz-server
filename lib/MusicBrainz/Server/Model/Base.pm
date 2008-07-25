package MusicBrainz::Server::Model::Base;

use strict;
use warnings;

use base 'Catalyst::Model';

sub ACCEPT_CONTEXT
{
    my ($self, $c) = @_;
    bless { _dbh => $c->mb->{DBH} }, ref $self;
}

1;
