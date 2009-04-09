package MusicBrainz::Server::Authentication::WebService;

use strict;
use warnings;

use MusicBrainz::Server::Editor;
use UserPreference;

sub new
{
    my ($class, $config, $app, $realm) = @_;
    bless { }, $class;
}

sub find_user
{
    my ($self, $authinfo, $c) = @_;
    return $c->model('User')->load({ username => $authinfo->{username} });
}

1;
