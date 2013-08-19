package MusicBrainz::Server::Controller::WS::1::User;
BEGIN { use Moose; extends 'MusicBrainz::Server::ControllerBase::WS::1' }

use HTTP::Status qw( :constants );
use MusicBrainz::Server::Constants qw/ $ACCESS_SCOPE_PROFILE /;
use MusicBrainz::Server::WebService::Serializer::XML::1::Utils qw( list_of );

__PACKAGE__->config(
    model => 'Artist',
);

my $ws_defs = Data::OptList::mkopt([
    user => {
        method   => 'GET',
    },
]);

with 'MusicBrainz::Server::WebService::Validator' => {
     defs    => $ws_defs,
     version => 1,
};

sub user_repository : Path('/ws/1/user') {
    my ($self, $c) = @_;

    return $self->bad_req($c, 'Only GET is acceptable')
        unless $c->req->method eq 'GET';

    $self->authenticate($c, $ACCESS_SCOPE_PROFILE);

    if ($c->req->query_params->{name} ne $c->user->name) {
        $c->res->status(HTTP_FORBIDDEN);
        $c->detach;
    }

    my $user = $c->model('Editor')->get_by_id($c->user->id)
        or $self->bad_req($c, 'Cannot load user');

    my $nag_status = $c->model('Editor')->donation_check($user);

    $c->stash->{serializer}->add_namespace( ext => 'http://musicbrainz.org/ns/ext-1.0#' );
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->xml(
        list_of(
            \'ext:user-list',
            [ $user ], undef, { nag => $nag_status }
        )
    ));
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
