package MusicBrainz::Server::Model::Url;

use strict;
use warnings;

use base 'Catalyst::Model';

use Carp;
use MusicBrainz::Server::Adapter 'LoadEntity';
use MusicBrainz::Server::Facade::Url;
use MusicBrainz::Server::Validation;
use MusicBrainz::Server::URL;

sub ACCEPT_CONTEXT
{
    my ($self, $c) = @_;
    bless { _dbh => $c->mb->{DBH} }, ref $self;
}

sub load
{
    my ($self, $id) = @_;

    my $url = MusicBrainz::Server::URL->new($self->{_dbh});
    LoadEntity($url, $id);

    return MusicBrainz::Server::Facade::Url->new_from_url($url);
}

1;
