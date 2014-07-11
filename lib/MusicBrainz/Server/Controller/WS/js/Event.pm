package MusicBrainz::Server::Controller::WS::js::Event;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion';
with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion::PrimaryAlias' => {
    model => 'Event',
};

my $ws_defs = Data::OptList::mkopt([
    "event" => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(direct limit page timestamp) ]
    }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
     version => 'js',
     default_serialization_type => 'json',
};

sub type { 'event' }

sub serialization_routine { '_event' }

sub search : Chained('root') PathPart('event')
{
    my ($self, $c) = @_;
    $self->dispatch_search($c);
}

around _format_output => sub {
    my ($orig, $self, $c, @entities) = @_;
    my %artists = $c->model('Event')->find_artists(\@entities, 3);

    return map +{
        %$_,
        artists => $artists{$_->{entity}->id},
    }, $self->$orig($c, @entities);
};

1;
