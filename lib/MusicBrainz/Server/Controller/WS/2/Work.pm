package MusicBrainz::Server::Controller::WS::2::Work;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Validation qw( is_guid );

my $ws_defs = Data::OptList::mkopt([
     work => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
     work => {
                         method   => 'GET',
                         inc      => [ qw(aliases annotation _relations
                                          tags user-tags
                                          genres user-genres
                                          moods user-moods
                                          ratings user-ratings) ],
                         optional => [ qw(fmt limit offset) ],
                         linked   => [ qw( artist collection ) ]
     },
     work => {
                         action   => '/ws/2/work/lookup',
                         method   => 'GET',
                         inc      => [ qw(aliases annotation _relations
                                          tags user-tags
                                          genres user-genres
                                          moods user-moods
                                          ratings user-ratings) ],
                         optional => [ qw(fmt) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::WS::2::Role::Lookup' => {
    model => 'Work',
};

with 'MusicBrainz::Server::Controller::WS::2::Role::BrowseByCollection';

sub work_toplevel
{
    my ($self, $c, $stash, $works) = @_;

    my $inc = $c->stash->{inc};
    my @works = @{$works};

    $self->linked_works($c, $stash, $works);

    $c->model('Work')->annotation->load_latest(@works)
        if $inc->annotation;

    $c->model('WorkAttribute')->load_for_works(@works);

    $self->load_relationships($c, $stash, @works);

    $c->model('WorkType')->load(@works);
}

sub base : Chained('root') PathPart('work') CaptureArgs(0) { }

sub work_browse : Private
{
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };
    my ($limit, $offset) = $self->_limit_and_offset($c);

    if (!is_guid($id))
    {
        $c->stash->{error} = 'Invalid mbid.';
        $c->detach('bad_req');
    }

    my $works;
    if ($resource eq 'artist') {
        my $artist = $c->model('Artist')->get_by_gid($id);
        $c->detach('not_found') unless $artist;

        my @tmp = $c->model('Work')->find_by_artist($artist->id, $limit, $offset);
        $works = $self->make_list(@tmp, $offset);
    } elsif ($resource eq 'collection') {
        $works = $self->browse_by_collection($c, 'work', $id, $limit, $offset);
    }

    my $stash = WebServiceStash->new;

    $self->work_toplevel($c, $stash, $works->{items});

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('work-list', $works, $c->stash->{inc}, $stash));
}

sub work_search : Chained('root') PathPart('work') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('work_browse') if ($c->stash->{linked});
    $self->_search($c, 'work');
}

1;
