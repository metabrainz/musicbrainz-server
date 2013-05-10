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
                         linked   => [ qw(release) ],
                         inc      => [ qw(aliases annotation
                                          _relations tags user-tags ratings user-ratings) ],
                         optional => [ qw(fmt limit offset) ],
     },
     label => {
                         method   => 'GET',
                         inc      => [ qw(releases aliases annotation
                                          _relations tags user-tags ratings user-ratings) ],
                         optional => [ qw(fmt) ],
     }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'Label'
};

Readonly our $MAX_ITEMS => 25;

sub base : Chained('root') PathPart('label') CaptureArgs(0) { }

sub label_toplevel
{
    my ($self, $c, $stash, $label) = @_;

    my $opts = $stash->store ($label);

    $self->linked_labels ($c, $stash, [ $label ]);

    $c->model('LabelType')->load($label);
    $c->model('Area')->load($label);
    $c->model('Area')->load_codes($label->area);
    $c->model('Label')->ipi->load_for($label);
    $c->model('Label')->isni->load_for($label);

    $c->model('Label')->annotation->load_latest($label)
        if $c->stash->{inc}->annotation;

    if ($c->stash->{inc}->aliases)
    {
        my $aliases = $c->model('Label')->alias->find_by_entity_id($label->id);
        $opts->{aliases} = $aliases;
    }

    if ($c->stash->{inc}->releases)
    {
        my @results = $c->model('Release')->find_by_label(
            $label->id, $MAX_ITEMS, 0, filter => { status => $c->stash->{status}, type => $c->stash->{type} });
        $opts->{releases} = $self->make_list (@results);

        $self->linked_releases ($c, $stash, $opts->{releases}->{items});
    }

    $self->load_relationships($c, $stash, $label);
}

sub label : Chained('load') PathPart('')
{
    my ($self, $c) = @_;
    my $label = $c->stash->{entity};

    return unless defined $label;

    my $stash = WebServiceStash->new;
    my $opts = $stash->store ($label);

    $self->label_toplevel ($c, $stash, $label);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('label', $label, $c->stash->{inc}, $stash));
}

sub label_browse : Private
{
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };
    my ($limit, $offset) = $self->_limit_and_offset ($c);

    if (!is_guid($id))
    {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $labels;
    my $total;
    if ($resource eq 'release')
    {
        my $release = $c->model('Release')->get_by_gid($id);
        $c->detach('not_found') unless ($release);

        my @tmp = $c->model('Label')->find_by_release ($release->id, $limit, $offset);
        $labels = $self->make_list (@tmp, $offset);
    }

    my $stash = WebServiceStash->new;

    for (@{ $labels->{items} })
    {
        $self->label_toplevel ($c, $stash, $_);
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('label-list', $labels, $c->stash->{inc}, $stash));
}

sub label_search : Chained('root') PathPart('label') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('label_browse') if ($c->stash->{linked});
    $self->_search ($c, 'label');
}

__PACKAGE__->meta->make_immutable;
1;

