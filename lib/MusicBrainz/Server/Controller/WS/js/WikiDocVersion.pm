package MusicBrainz::Server::Controller::WS::js::WikiDocVersion;
use Moose;
use Text::Trim qw( trim );


BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

my $ws_defs = Data::OptList::mkopt([
    "wikidocversion" => {
        method   => 'GET',
        required => [ qw(title) ],
    }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
     version => 'js',
     default_serialization_type => 'json',
};

sub version : Chained('root') PathPart('wikidocversion') {
    my ($self, $c) = @_;

    my $title = trim $c->stash->{args}->{title};

    unless ($title) {
        $c->detach('bad_req');
    }

    my $output = $c->model('WikiDoc')->get_version ($title);
    
    $output->{server} = &DBDefs::WIKITRANS_SERVER;

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('generic', $output));
};

1;
