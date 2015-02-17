package MusicBrainz::Server::Plugin::Canonicalize;

use strict;
use warnings;

use base 'Template::Plugin';
use DBDefs;

sub canonicalize
{
    my ($self, $url) = @_;

    if (DBDefs->CANONICAL_SERVER) {
        my $ws = DBDefs->WEB_SERVER;
        my $canon = DBDefs->CANONICAL_SERVER;
        $url =~ s{^(https?:)?//$ws}{$canon};
    }

    return $url;
}

sub replace_gid
{
    my ($self, $c, $new_gid) = @_;
    my $new_captures = [$new_gid];
    push(@$new_captures, @{ $c->req->captures }[1..scalar(@{ $c->req->captures })-1]);
    return $c->uri_for_action($c->action->private_path, $new_captures, @{ $c->req->args }, $c->req->query_params);
}

1;
