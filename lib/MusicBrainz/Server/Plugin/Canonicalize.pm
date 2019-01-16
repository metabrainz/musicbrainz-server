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

1;
