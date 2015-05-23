package MusicBrainz::Server::Renderer;

use strict;
use warnings;

use base 'Exporter';
use charnames ':alias' => {INFO_SEP => 'INFORMATION SEPARATOR ONE'};
use DBDefs;
use Encode;
use HTML::Entities qw( encode_entities decode_entities );
use HTTP::Request;
use JSON -convert_blessed_universally;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use URI;

my %URI_DELIMITERS = (
    uri_for => "\N{INFO_SEP}__URI_FOR__\N{INFO_SEP}",
    uri_for_action => "\N{INFO_SEP}__URI_FOR_ACTION__\N{INFO_SEP}",
);

our @EXPORT_OK = qw(
    create_request
);

sub create_request {
    my ($path, $headers, $body) = @_;

    my $uri = URI->new;
    $uri->scheme('http');
    $uri->host(DBDefs->RENDERER_HOST || '127.0.0.1');
    $uri->port(DBDefs->RENDERER_PORT);
    $uri->path($path);

    HTTP::Request->new('GET', $uri, $headers, $body);
}

sub replace_uri {
    my ($c, $method, $args) = @_;

    $args = JSON->new->decode(decode_entities($args));
    return encode_entities($c->$method(@{$args}));
}

sub handle_request {
    my ($c) = @_;

    my $user;
    if ($c->user_exists) {
        $user = {%{$c->user->TO_JSON}, preferences => $c->user->preferences};
    }

    my $body = $c->json_utf8->encode({
        context => {
            user => $user,
            debug => boolean_to_json($c->debug),
            stash => $c->stash,
            sessionid => scalar($c->sessionid),
            session => $c->session,
            flash => $c->flash,
        }});

    my $response = $c->model('MB')->context->lwp->request(
        create_request($c->req->path, $c->req->headers->clone, $body)
    );

    my $content = decode('utf-8', $response->content);

    # URI replacement magic.
    for my $method (keys %URI_DELIMITERS) {
        my $delimiter = $URI_DELIMITERS{$method};

        $content =~ s/$delimiter ([^\N{INFO_SEP}]+) $delimiter
                     /replace_uri($c, $method, $1)/xmseg;
    }

    $c->res->status($response->code);
    $c->res->body($content);
}

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
