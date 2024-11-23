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
            $res->header('Access-Control-Allow-Headers' => 'Authorization, Content-Type, User-Agent');
        }

        $c->detach;
    }
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
