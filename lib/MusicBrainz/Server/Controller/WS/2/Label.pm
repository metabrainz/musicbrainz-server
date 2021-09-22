package MusicBrainz::Server::Controller::WS::2::Label;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Validation qw( is_guid );
use Readonly;

my $ws_defs = Data::OptList::mkopt([
     label => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
     label => {
                         method   => 'GET',
                         linked   => [ qw(area release collection) ],
                         inc      => [ qw(aliases annotation
                                          _relations tags user-tags genres user-genres ratings user-ratings) ],
                         optional => [ qw(fmt limit offset) ],
     },
     label => {
                         action   => '/ws/2/label/lookup',
                         method   => 'GET',
                         inc      => [ qw(releases aliases annotation
                                          _relations tags user-tags genres user-genres ratings user-ratings) ],
                         optional => [ qw(fmt) ],
     }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::WS::2::Role::Lookup' => {
    model => 'Label',
};

with 'MusicBrainz::Server::Controller::WS::2::Role::BrowseByCollection';

Readonly our $MAX_ITEMS => 25;

sub base : Chained('root') PathPart('label') CaptureArgs(0) { }

sub label_toplevel {
    my ($self, $c, $stash, $labels) = @_;

    my $inc = $c->stash->{inc};
    my @labels = @{$labels};

    $self->linked_labels($c, $stash, $labels);

    $c->model('LabelType')->load(@labels);
    $c->model('Area')->load(@labels);
    $c->model('Label')->ipi->load_for(@labels);
    $c->model('Label')->isni->load_for(@labels);

    $c->model('Label')->annotation->load_latest(@labels)
        if $inc->annotation;

    $self->load_relationships($c, $stash, @labels);

    if ($inc->releases) {
        my @releases;
        for my $label (@labels) {
            my $opts = $stash->store($label);
            my @results = $c->model('Release')->find_by_label(
                $label->id, $MAX_ITEMS, 0, filter => { status => $c->stash->{status}, type => $c->stash->{type} });
            $opts->{releases} = $self->make_list(@results);
            push @releases, @{ $opts->{releases}{items} };
        }
        $self->linked_releases($c, $stash, \@releases) if @releases;
    }
}

sub label_browse : Private
{
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };
    my ($limit, $offset) = $self->_limit_and_offset($c);

    if (!is_guid($id))
    {
        $c->stash->{error} = 'Invalid mbid.';
        $c->detach('bad_req');
    }

    my $labels;
    if ($resource eq 'area') {
        my $area = $c->model('Area')->get_by_gid($id);
        $c->detach('not_found') unless ($area);

        my @tmp = $c->model('Label')->find_by_area($area->id, $limit, $offset);
        $labels = $self->make_list(@tmp, $offset);
    } elsif ($resource eq 'collection') {
        $labels = $self->browse_by_collection($c, 'label', $id, $limit, $offset);
    } elsif ($resource eq 'release') {
        my $release = $c->model('Release')->get_by_gid($id);
        $c->detach('not_found') unless ($release);

        my @tmp = $c->model('Label')->find_by_release($release->id, $limit, $offset);
        $labels = $self->make_list(@tmp, $offset);
    }

    my $stash = WebServiceStash->new;

    $self->label_toplevel($c, $stash, $labels->{items});

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('label-list', $labels, $c->stash->{inc}, $stash));
}

sub label_search : Chained('root') PathPart('label') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('label_browse') if ($c->stash->{linked});
    $self->_search($c, 'label');
}

__PACKAGE__->meta->make_immutable;
1;

