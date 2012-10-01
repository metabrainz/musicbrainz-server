package MusicBrainz::Server::Controller::Role::ETags;
use Moose::Role;
use namespace::autoclean;
use Digest::MD5 qw( md5_hex );

after end => sub {
    my ($self, $c) = @_;

    my $body = $c->response->body;
    if ($body) {
        utf8::encode($body)
            if utf8::is_utf8($body);
        $c->response->headers->etag(md5_hex($body));
    }
};

1;
