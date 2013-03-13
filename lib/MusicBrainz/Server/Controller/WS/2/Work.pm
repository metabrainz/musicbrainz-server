package MusicBrainz::Server::Controller::WS::2::Work;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Validation qw( is_guid );
use Readonly;

my $ws_defs = Data::OptList::mkopt([
     work => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
     work => {
                         method   => 'GET',
                         inc      => [ qw(aliases annotation _relations
                                          tags user-tags ratings user-ratings) ],
                         optional => [ qw(fmt limit offset) ],
                         linked   => [ qw( artist ) ]
     },
     work => {
                         method   => 'GET',
                         inc      => [ qw(aliases annotation _relations
                                          tags user-tags ratings user-ratings) ],
                         optional => [ qw(fmt) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'Work'
};

sub work_toplevel
{
    my ($self, $c, $stash, $work) = @_;

    my $opts = $stash->store ($work);

    $self->linked_works ($c, $stash, [ $work ]);

    $c->model('Work')->annotation->load_latest($work)
        if $c->stash->{inc}->annotation;

    $self->load_relationships($c, $stash, $work);

    $c->model('WorkType')->load($work);
    $c->model('Language')->load($work);
}

sub base : Chained('root') PathPart('work') CaptureArgs(0) { }

sub work : Chained('load') PathPart('')
{
    my ($self, $c) = @_;
    my $work = $c->stash->{entity};

    return unless defined $work;

    my $stash = WebServiceStash->new;
    my $opts = $stash->store ($work);

    $self->work_toplevel ($c, $stash, $work);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('work', $work, $c->stash->{inc}, $stash));
}

sub work_browse : Private
{
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };
    my ($limit, $offset) = $self->_limit_and_offset ($c);

    if (!is_guid($id))
    {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $works;
    my $total;
    if ($resource eq 'artist') {
        my $artist = $c->model('Artist')->get_by_gid($id);
        $c->detach('not_found') unless $artist;

        my @tmp = $c->model('Work')->find_by_artist($artist->id, $limit, $offset);
        $works = $self->make_list(@tmp, $offset);
    }

    my $stash = WebServiceStash->new;

    for (@{ $works->{items} })
    {
        $self->work_toplevel ($c, $stash, $_);
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('work-list', $works, $c->stash->{inc}, $stash));
}

sub work_search : Chained('root') PathPart('work') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('work_browse') if ($c->stash->{linked});
    $self->_search ($c, 'work');
}

1;
