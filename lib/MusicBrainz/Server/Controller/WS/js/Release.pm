package MusicBrainz::Server::Controller::WS::js::Release;
use Moose;
use JSON qw( encode_json );
use aliased 'MusicBrainz::Server::Entity::Work';
use MusicBrainz::Server::Validation qw( is_guid );
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion::WithArtistCredits';
with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion::PrimaryAlias' => {
    model => 'Release',
};

my $ws_defs = Data::OptList::mkopt([
    'release' => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(direct limit page timestamp) ]
    },
    'release' => {
        method => 'GET',
        inc => [ qw(recordings rels) ]
    },
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

after _load_entities => sub {
    my ($self, $c, @releases) = @_;

    $c->model('Release')->annotation->load_latest(@releases);
    $c->model('Release')->load_release_events(@releases);
    $c->model('ReleaseLabel')->load(@releases);
    $c->model('Label')->load(map { $_->all_labels } @releases);
    $c->model('Medium')->load_for_releases(@releases);
    my @mediums = map { $_->all_mediums } @releases;
    $c->model('MediumFormat')->load(@mediums);
    $c->model('MediumCDTOC')->load_for_mediums(@mediums);
    $c->model('CDTOC')->load(map { $_->all_cdtocs } @mediums);
};

sub release : Chained('root') PathPart('release') Args(1)
{
    my ($self, $c, $gid) = @_;

    if (!is_guid($gid)) {
        $c->stash->{error} = 'Invalid mbid.';
        $c->detach('bad_req');
    }

    my $release = $c->model('Release')->get_by_gid($gid);

    unless (defined $release) {
        $c->stash->{error} = "Release $gid does not exist.";
        $c->detach('bad_req');
    }

    $c->model('ReleaseGroup')->load($release);
    $c->model('ReleaseGroupType')->load($release->release_group);
    $c->model('ReleaseGroup')->load_meta($release->release_group);
    $c->model('ArtistCredit')->load($release, $release->release_group);
    $c->model('ReleasePackaging')->load($release);

    $self->_load_entities($c, $release);

    my $inc = $c->stash->{inc};

    if ($inc->recordings) {
        $c->model('Track')->load_for_mediums($release->all_mediums);
        my @tracks = map { $_->all_tracks } $release->all_mediums;
        $c->model('ArtistCredit')->load(@tracks);

        my @recordings = $c->model('Recording')->load(@tracks);
        $c->model('Recording')->load_meta(@recordings);
        $c->model('ArtistCredit')->load(@recordings);

        if ($inc->rels) {
            $c->model('Relationship')->load_cardinal(@recordings);
            my @recording_rels = map { $_->all_relationships } @recordings;
            my @works = grep { $_->isa(Work) } map { $_->target } @recording_rels;
            $c->model('Relationship')->load_cardinal(@works);
        }
    }

    if ($inc->rels) {
        $c->model('Relationship')->load_cardinal($release->release_group, $release);
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body(encode_json($release->TO_JSON));
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
