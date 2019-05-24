package MusicBrainz::Server::Controller::Role::CORS;
use Moose::Role;
use namespace::autoclean;

before begin => sub {
    my ($self, $c) = @_;
    $c->res->header('Access-Control-Allow-Origin' => '*');
};

after begin => sub {
    my ($self, $c) = @_;

    my $req = $c->req;
    if ($req->method eq 'OPTIONS' && $self->can('allowed_http_methods')) {
        my $res = $c->res;
        my $allow = join q(, ), $self->allowed_http_methods, 'OPTIONS';
        $res->header('Allow' => $allow);

        if ($req->header('Origin') && $req->header('Access-Control-Request-Method')) {
            # CORS preflight
            $res->header('Access-Control-Allow-Methods' => $allow);
            $res->header('Access-Control-Allow-Headers' => 'Authorization, Content-Type');
        }

        $c->detach;
    }
};

1;
