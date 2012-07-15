package MusicBrainz::Server::View::Default;

use strict;
use base 'Catalyst::View::TT';
use DBDefs;
use MRO::Compat;
use Digest::MD5 qw( md5_hex );
use MusicBrainz::Server::Translation;

__PACKAGE__->config(TEMPLATE_EXTENSION => '.tt');

sub process
{
    my $self = shift;
    my $c = $_[0];

    MusicBrainz::Server::Translation->instance->_set_language();
    my $ret = $self->next::method(@_);
    MusicBrainz::Server::Translation->instance->_unset_language();
    $ret or return 0;

    return 1 unless &DBDefs::USE_ETAGS;

    my $method = $c->request->method;
    return 1
        if $method ne 'GET' and $method ne 'HEAD' or
            $c->stash->{nocache};    # disable caching explicitely

    my $body = $c->response->body;
    if ($body) {
        utf8::encode($body)
            if utf8::is_utf8($body);
        $c->response->headers->etag(md5_hex($body));
    }

    return 1;
}

1;
