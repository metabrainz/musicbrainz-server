package MusicBrainz::Server::Controller::WS::js::Release;
use Moose;
use aliased 'MusicBrainz::Server::Entity::Work';
use MusicBrainz::Server::Validation qw( is_guid );
use Scalar::Util qw( blessed );
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
        inc => [ qw(recordings rels annotation release-events labels media) ]
    },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
     version => 'js',
     default_serialization_type => 'json',
};

sub type { 'release' }

sub serialization_routine { '_release' }

sub search : Chained('root') PathPart('release')
{
    my ($self, $c) = @_;
    $self->dispatch_search($c);
}

sub _load_entities
{
    my ($self, $c, @releases) = @_;

    return @releases unless blessed $c->stash->{inc};

    if ($c->stash->{inc}->release_events) {
        $c->model('Release')->load_release_events(@releases);
    }

    if ($c->stash->{inc}->labels) {
        $c->model('ReleaseLabel')->load(@releases);
        $c->model('Label')->load(map { $_->all_labels } @releases);
    }

    if ($c->stash->{inc}->media || $c->stash->{inc}->recordings) {
        $c->model('Medium')->load_for_releases(@releases);
        $c->model('MediumFormat')->load(map { $_->all_mediums } @releases);
    }

    return @releases;
}

sub release : Chained('root') PathPart('release') Args(1)
{
    my ($self, $c, $gid) = @_;

    if (!is_guid($gid)) {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $release = $c->model('Release')->get_by_gid($gid);

    unless (defined $release) {
        $c->stash->{error} = "Release $gid does not exist.";
        $c->detach('bad_req');
    }

    $c->model('ReleaseGroup')->load($release);
    $c->model('ReleaseGroup')->load_meta($release->release_group);
    $c->model('ArtistCredit')->load($release, $release->release_group);
    $c->model('ReleasePackaging')->load($release);

    $self->_load_entities($c, $release);

    if ($c->stash->{inc}->annotation) {
        $c->model('Release')->annotation->load_latest($release);
    }

    if ($c->stash->{inc}->media || $c->stash->{inc}->recordings) {
        $c->model('MediumCDTOC')->load_for_mediums($release->all_mediums);
        $c->model('CDTOC')->load(map { $_->all_cdtocs } $release->all_mediums);
    }

    if ($c->stash->{inc}->recordings) {
        $c->model('Track')->load_for_mediums($release->all_mediums);
        my @tracks = map { $_->all_tracks } $release->all_mediums;
        $c->model('ArtistCredit')->load(@tracks);

        my @recordings = $c->model('Recording')->load(@tracks);
        $c->model('Recording')->load_meta(@recordings);
        $c->model('ArtistCredit')->load(@recordings);

        if ($c->stash->{inc}->rels) {
            $c->model('Relationship')->load_cardinal(@recordings);
            my @recording_rels = map { $_->all_relationships } @recordings;
            my @works = grep { $_->isa(Work) } map { $_->target } @recording_rels;
            $c->model('Relationship')->load_cardinal(@works);
        }
    }

    if ($c->stash->{inc}->rels) {
        $c->model('Relationship')->load_cardinal($release->release_group, $release);
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize_release($c, $release));
}

1;
