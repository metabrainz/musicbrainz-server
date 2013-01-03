package MusicBrainz::Server::Controller::WS::2::DiscID;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' };

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Validation qw( is_valid_discid );
use MusicBrainz::Server::Translation qw( l );
use Readonly;

my $ws_defs = Data::OptList::mkopt([
     discid => {
                         method   => 'GET',
                         inc      => [ qw(artists labels recordings release-groups artist-credits
                                          aliases puids isrcs _relations cdstubs ) ],
                         optional => [ qw( fmt ) ],
     }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

sub discid : Chained('root') PathPart('discid') Args(1)
{
    my ($self, $c, $id) = @_;

    if (!is_valid_discid($id))
    {
        $c->stash->{error} = "Invalid discid.";
        $c->detach('bad_req');
    }

    if (my $cdstubs = $c->req->query_params->{cdstubs}) {
        $self->bad_req($c, 'Invalid argument "cdstubs": must be "yes" or "no"')
            unless $cdstubs eq 'yes' || $cdstubs eq 'no';
    }

    if (my $toc = $c->req->query_params->{toc}) {
        $self->bad_req($c, 'Invalid argument "toc"')
            if ref($toc);
    }

    $c->stash->{inc}->media (1);
    $c->stash->{inc}->discids (1);

    my $stash = WebServiceStash->new;
    my $cdtoc = $c->model('CDTOC')->get_by_discid($id);
    if ($cdtoc) {
        my @mediumcdtocs = $c->model('MediumCDTOC')->find_by_discid($cdtoc->discid);
        $c->model('Medium')->load(@mediumcdtocs);

        my $opts = $stash->store ($cdtoc);

        my @releases = $c->model('Release')->find_by_medium(
            [ map { $_->medium_id } @mediumcdtocs ], $c->stash->{status}, $c->stash->{type}
        );

        $opts->{releases} = $self->make_list (\@releases);

        for (@releases) {
            $c->controller('WS::2::Release')->release_toplevel($c, $stash, $_);
        }

        $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
        $c->res->body($c->stash->{serializer}->serialize('discid', $cdtoc, $c->stash->{inc}, $stash));
        return;
    }

    if (!exists $c->req->query_params->{cdstubs} || $c->req->query_params->{cdstubs} eq 'yes')
    {
        my $cd_stub_toc = $c->model('CDStubTOC')->get_by_discid($id);
        if ($cd_stub_toc) {
            $c->model('CDStub')->load($cd_stub_toc);
            $c->model('CDStub')->increment_lookup_count($cd_stub_toc->cdstub->id);
            $c->model('CDStubTrack')->load_for_cdstub($cd_stub_toc->cdstub);
            $cd_stub_toc->update_track_lengths;

            $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
            $c->res->body($c->stash->{serializer}->serialize('cdstub', $cd_stub_toc, $c->stash->{inc}, $stash));
            return;
        }
    }

    if (my $toc = $c->req->query_params->{toc}) {
        my $results = $c->model('DurationLookup')->lookup($toc, 10000);
        if (!defined($results)) {
            $self->_error($c, l('Invalid TOC'));
        }

        my $inc = $c->stash->{inc};

        $c->model('MediumFormat')->load(map { $_->medium } @$results);

        my @mediums = grep { $_->may_have_discids } map { $_->medium } @$results;
        $c->model('Release')->load(@mediums);

        my @releases = map { $_->release } @mediums;
        $c->controller('WS::2::Release')->release_toplevel($c, $stash, $_)
            for @releases;

        $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
        $c->res->body($c->stash->{serializer}->serialize(
            'release_list',
            {
                items => \@releases
            },
            $c->stash->{inc}, $stash
        ));

        return;
    }

    $c->detach('not_found');
}

__PACKAGE__->meta->make_immutable;
1;

