package MusicBrainz::Server::Controller::WS::2::ReleaseGroup;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::ControllerUtils::Release qw( load_release_events );
use MusicBrainz::Server::Validation qw( is_guid );
use Readonly;

my $ws_defs = Data::OptList::mkopt([
     "release-group" => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
     "release-group" => {
                         method   => 'GET',
                         linked   => [ qw(artist release) ],
                         inc      => [ qw(artist-credits annotation
                                          _relations tags user-tags ratings user-ratings) ],
                         optional => [ qw(fmt limit offset) ],
     },
     "release-group" => {
                         method   => 'GET',
                         inc      => [ qw(artists releases artist-credits aliases annotation
                                          _relations tags user-tags ratings user-ratings) ],
                         optional => [ qw(fmt) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'ReleaseGroup'
};

Readonly our $MAX_ITEMS => 25;

sub release_group_toplevel
{
    my ($self, $c, $stash, $rg) = @_;

    $c->model('ReleaseGroup')->load_meta($rg);

    my $opts = $stash->store ($rg);

    $self->linked_release_groups ($c, $stash, [ $rg ]);

    $c->model('ReleaseGroup')->annotation->load_latest($rg)
        if $c->stash->{inc}->annotation;

    if ($c->stash->{inc}->releases)
    {
        my @results = $c->model('Release')->find_by_release_group(
            $rg->id, $MAX_ITEMS, 0, filter => { status => $c->stash->{status} });
        load_release_events($c, @{$results[0]});
        $opts->{releases} = $self->make_list (@results);

        $self->linked_releases ($c, $stash, $opts->{releases}->{items});
    }

    if ($c->stash->{inc}->artists)
    {
        $c->model('ArtistCredit')->load($rg);

        my @artists = map { $c->model('Artist')->load ($_); $_->artist } @{ $rg->artist_credit->names };

        $self->linked_artists ($c, $stash, \@artists);
    }

    $self->load_relationships($c, $stash, $rg);
}

sub base : Chained('root') PathPart('release-group') CaptureArgs(0) { }

sub release_group : Chained('load') PathPart('')
{
    my ($self, $c) = @_;
    my $rg = $c->stash->{entity};

    return unless defined $rg;

    my $stash = WebServiceStash->new;

    $self->release_group_toplevel ($c, $stash, $rg);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('release-group', $rg, $c->stash->{inc}, $stash));
}

sub release_group_browse : Private
{
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };
    my ($limit, $offset) = $self->_limit_and_offset ($c);

    if (!is_guid($id))
    {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $rgs;
    my $total;
    if ($resource eq 'artist')
    {
        my $artist = $c->model('Artist')->get_by_gid($id);
        $c->detach('not_found') unless ($artist);

        my @tmp = $c->model('ReleaseGroup')->find_by_artist (
            $artist->id, $limit, $offset, filter => { type => $c->stash->{type} });
        $rgs = $self->make_list (@tmp, $offset);
    }
    elsif ($resource eq 'release')
    {
        my $release = $c->model('Release')->get_by_gid($id);
        $c->detach('not_found') unless ($release);

        my @tmp = $c->model('ReleaseGroup')->find_by_release ($release->id, $limit, $offset);
        $rgs = $self->make_list (@tmp, $offset);
    }

    my $stash = WebServiceStash->new;

    for (@{ $rgs->{items} })
    {
        $self->release_group_toplevel ($c, $stash, $_);
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('release-group-list', $rgs, $c->stash->{inc}, $stash));
}

sub release_group_search : Chained('root') PathPart('release-group') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('release_group_browse') if ($c->stash->{linked});

    $self->_search ($c, 'release-group');
}

__PACKAGE__->meta->make_immutable;
1;

