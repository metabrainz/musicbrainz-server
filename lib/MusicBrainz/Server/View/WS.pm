package MusicBrainz::Server::View::WS;

use strict;
use warnings;

use base 'Catalyst::View';
use Date::Calc qw( Today_and_Now Add_Delta_DHMS Date_to_Time );
use DBDefs;
use Digest::MD5 qw( md5_hex );

sub process {
    my ($self, $c) = @_;

    if (scalar @{ $c->stash->{errors} }) {
        $c->res->content_type('text/plain; charset=utf-8');
        $c->res->body(join "\n", @{ $c->stash->{errors} });
        return 1;
    }

    return 1 unless DBDefs->USE_ETAGS;

    my $method = $c->request->method;
    if ($method ne 'GET' and $method ne 'HEAD' or $c->stash->{nocache}) {
        # disable caching explicitely
        return 1;
    }

    my $body = $c->response->body;
    if ($body) {
        utf8::encode($body) if utf8::is_utf8($body);
        $c->response->headers->etag(md5_hex($body));

        if (DBDefs->REPLICATION_TYPE eq DBDefs->RT_MIRROR && !$c->res->headers->expires) {
            my @today = Today_and_Now(1);
            my $next_hour = Date_to_Time(
                Add_Delta_DHMS($today[0], $today[1], $today[2], $today[3], 10, 0, 0, 1, 0, 0)
            );
            my $this_hour = Date_to_Time($today[0], $today[1], $today[2], $today[3], 10, 0);
            $c->res->headers->expires($next_hour);
            $c->res->headers->last_modified($this_hour);
        }
    }

    return 1;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
