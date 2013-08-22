package MusicBrainz::Server::Controller::WS::js::Work;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion';

my $ws_defs = Data::OptList::mkopt([
    "work" => {
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

sub type { 'work' }

sub serialization_routine { '_work' }

sub search : Chained('root') PathPart('work')
{
    my ($self, $c) = @_;
    $self->dispatch_search($c);
}

sub _format_output {
    my ($self, $c, @entities) = @_;
    my %artists = $c->model('Work')->find_artists(\@entities, 3);
    my $aliases = $c->model('Work')->alias->find_by_entity_ids(
        map { $_->id } @entities);

    $c->model('Language')->load(@entities);

    return map {
        {
            work => $_,
            aliases => $aliases->{$_->id},
            artists => $artists{$_->id}
        }
    } @entities;
}

1;

