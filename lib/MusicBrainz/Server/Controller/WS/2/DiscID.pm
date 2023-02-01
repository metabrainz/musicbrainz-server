package MusicBrainz::Server::Controller::WS::2::DiscID;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' };

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Validation qw( is_valid_discid );
use MusicBrainz::Server::Translation qw( l );

# A duration lookup has to match within this many milliseconds
use constant DURATION_LOOKUP_RANGE => 10000;

my $ws_defs = Data::OptList::mkopt([
     discid => {
                         method   => 'GET',
                         inc      => [ qw(artists labels recordings release-groups artist-credits                                          tags user-tags genres user-genres
                                          tags user-tags genres user-genres
                                          aliases puids isrcs _relations cdstubs ) ],
                         optional => [ qw( fmt limit offset ) ],
     }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

sub discid : Chained('root') PathPart('discid') {
    my ($self, $c, $id) = @_;

    if (!is_valid_discid($id) && !(exists $c->req->query_params->{toc}))
    {
        $c->stash->{error} = 'Invalid discid.';
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

    my ($limit, $offset) = $self->_limit_and_offset($c);
    $limit = 25 if $limit > 25;

    $c->stash->{inc}->media(1);
    $c->stash->{inc}->discids(1);

    my $stash = WebServiceStash->new;
    if (is_valid_discid($id)) {
        my $cdtoc = $c->model('CDTOC')->get_by_discid($id);
        if ($cdtoc) {
            my @mediumcdtocs = $c->model('MediumCDTOC')->find_by_discid($cdtoc->discid);
            $c->model('Medium')->load(@mediumcdtocs);

            my $opts = $stash->store($cdtoc);

            my ($releases, $hits) = $c->model('Release')->find_by_medium(
                [map { $_->medium_id } @mediumcdtocs],
                $limit, $offset
            );

            $opts->{releases} = $self->make_list($releases, $hits, $offset);

            $c->controller('WS::2::Release')->release_toplevel($c, $stash, $releases);

            $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
            $c->res->body($c->stash->{serializer}->serialize('disc', $cdtoc, $c->stash->{inc}, $stash));
            return;
        }

        if (!exists $c->req->query_params->{cdstubs} || $c->req->query_params->{cdstubs} eq 'yes')
        {
            my $cdstub = $c->model('CDStub')->get_by_discid($id);
            if ($cdstub) {
                $c->model('CDStub')->increment_lookup_count($cdstub->id);
                $c->model('CDStubTrack')->load_for_cdstub($cdstub);
                $cdstub->update_track_lengths;

                $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
                $c->res->body($c->stash->{serializer}->serialize('cdstub', $cdstub, $c->stash->{inc}, $stash));
                return;
            }
        }
    }

    if (my $toc = $c->req->query_params->{toc}) {
        my $all_formats = 0;
        if (exists $c->req->query_params->{'media-format'} &&
                   $c->req->query_params->{'media-format'} eq 'all') {
            $all_formats = 1;
        }

        my ($results, $hits) = $c->model('DurationLookup')->lookup(
            $toc, DURATION_LOOKUP_RANGE, $all_formats, $limit, $offset);
        if (!defined($results)) {
            $self->_error($c, l('Invalid TOC'));
        }

        my $inc = $c->stash->{inc};
        my @release_ids = map { $_->{release} } @{$results};
        my $releases = $c->model('Release')->get_by_ids(@release_ids);
        my @releases = map { $releases->{$_} } @release_ids;
        my $release_list = $self->make_list(\@releases, $hits, $offset);

        $self->limit_releases_by_tracks($c, $release_list->{items})
            if $inc->recordings;
        $c->controller('WS::2::Release')->release_toplevel($c, $stash, $release_list->{items});

        $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
        $c->res->body($c->stash->{serializer}->serialize(
            'release_list',
            $release_list,
            $inc, $stash
        ));

        return;
    }

    $c->detach('not_found');
}

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
