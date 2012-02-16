package MusicBrainz::Server::Controller::WS::js::CAA;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller'; }

use namespace::autoclean;
use HTTP::Request::Common;
use Readonly;

Readonly my %serializers => (
    json => 'MusicBrainz::Server::WebService::JSONSerializer',
);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => Data::OptList::mkopt([
         "exists" => {
             method => 'GET',
             required => [qw (mbid type index )]
         }
     ]),
     version => 'js',
     default_serialization_type => 'json',
};

sub exists : Path('/ws/js/caa/exists'){
    my ($self, $c) = @_;

    my %qp = %{$c->req->query_params};
    my ($mbid, $type, $index) = @qp{qw( mbid type index )};

    my $lwp = LWP::UserAgent->new;
    my $url = sprintf('http://coverartarchive.org/release/%s/%s-%s.jpg',
                      $mbid, $type, $index);
    warn $url;
    my $res = $lwp->request(HEAD $url);

    $c->response->code($res->code);
}

__PACKAGE__->meta->make_immutable;
1;
