package MusicBrainz::Server::View::Default;

use strict;
use base 'Catalyst::View::TT';
use DBDefs;
use MRO::Compat;
use Digest::MD5 qw( md5_hex );
use MusicBrainz::Server::Translation;
use Date::Calc qw( Today_and_Now Add_Delta_DHMS Date_to_Time );

__PACKAGE__->config(TEMPLATE_EXTENSION => '.tt');

sub process
{
    my $self = shift;
    my $c = $_[0];


    $self->next::method(@_) or return 0;

    return 1 unless DBDefs->USE_ETAGS;

    my $method = $c->request->method;
    return 1
        if $method ne 'GET' and $method ne 'HEAD' or
            $c->stash->{nocache};    # disable caching explicitely

    my $body = $c->response->body;
    if ($body) {
        utf8::encode($body)
            if utf8::is_utf8($body);
        $c->response->headers->etag(md5_hex($body));
        if (DBDefs->REPLICATION_TYPE eq DBDefs->RT_SLAVE && !$c->res->headers->expires) {
            my @today = Today_and_Now(1);
            my $next_hour = Date_to_Time(Add_Delta_DHMS($today[0], $today[1], $today[2], $today[3], 10, 0,
                                                       0, 1, 0, 0));
            my $this_hour = Date_to_Time($today[0], $today[1], $today[2], $today[3], 10, 0);
            $c->res->headers->expires($next_hour);
            $c->res->headers->last_modified($this_hour);
        }
    }

    return 1;
}

1;
