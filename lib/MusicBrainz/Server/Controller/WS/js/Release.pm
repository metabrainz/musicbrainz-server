package MusicBrainz::Server::Controller::WS::js::Release;
use Moose;
use aliased 'MusicBrainz::Server::Entity::Work';
use MusicBrainz::Server::Validation qw( is_guid );
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion';

my $ws_defs = Data::OptList::mkopt([
    "release" => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(direct limit page timestamp) ]
    },
    "release" => {
        method => 'GET',
        inc => [ qw(recordings rels) ]
    }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
     version => 'js',
     default_serialization_type => 'json',
};

sub type { 'release' }

sub search : Chained('root') PathPart('release')
{
    my ($self, $c) = @_;
    $self->dispatch_search($c);
}

sub release : Chained('root') PathPart('release') Args(1)
{
    my ($self, $c, $gid) = @_;

    if (!is_guid($gid)) {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $release = $c->model('Release')->get_by_gid($gid);
    $c->model('ReleaseGroup')->load($release);
    $c->model('ReleaseGroup')->load_meta($release->release_group);
    $c->model('Relationship')->load($release->release_group);
    $c->model('Medium')->load_for_releases($release);
    $c->model('MediumFormat')->load($release->all_mediums);
    my @tracklists = map { $_->tracklist } $release->all_mediums;
    $c->model('Track')->load_for_tracklists(@tracklists);
    my @tracks = map { $_->all_tracks } @tracklists;
    $c->model('ArtistCredit')->load($release, $release->release_group, @tracks);

    if ($c->stash->{inc}->recordings) {
        my @recordings = $c->model('Recording')->load(@tracks);
        $c->model('Recording')->load_meta(@recordings);
        $c->model('ArtistCredit')->load(@recordings);

        if ($c->stash->{inc}->rels) {
            $c->model('Relationship')->load(@recordings);
            my @recording_rels = map { $_->all_relationships } @recordings;
            my @works = grep { $_->isa(Work) } map { $_->target } @recording_rels;
            $c->model('Relationship')->load(@works);
        }
    }

    $c->model('Relationship')->load($release) if $c->stash->{inc}->rels;

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize_release($c, $release));
}

1;

