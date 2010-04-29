package MusicBrainz::Server::Controller::WS::1;

use Moose;
use Readonly;
BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::WebService::XMLSerializerV1;
use MusicBrainz::Server::WebService::Validator;

# This defines what options are acceptable for WS calls
# rel_status and rg_type are special cases that allow for one release status and one release group
# type per call to be specified.
my $ws_defs = Data::OptList::mkopt([
     "release-group" => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(limit offset) ]
     },
     "release-group" => {
                         method   => 'GET',
                         inc      => [ qw(artist releases) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
     version => 1,
};

Readonly my %serializers => (
    xml => 'MusicBrainz::Server::WebService::XMLSerializerV1',
);

sub bad_req : Private
{
    my ($self, $c) = @_;
    $c->res->status(400);
    $c->res->content_type("text/plain; charset=utf-8");
    $c->res->body($c->stash->{serializer}->output_error($c->stash->{error}.
                  "\nFor usage, please see: http://musicbrainz.org/development/mmd\015\012"));
}

sub not_found : Private
{
    my ($self, $c) = @_;
    $c->res->status(404);
}

sub begin : Private
{
}

sub end : Private
{
}

sub root : Chained('/') PathPart("ws/1") CaptureArgs(0)
{
    my ($self, $c) = @_;
    $self->validate($c, \%serializers) or $c->detach('bad_req');
}

sub release_group : Chained('root') PathPart('release-group') Args(1)
{
    my ($self, $c, $gid) = @_;

    if (!MusicBrainz::Server::Validation::IsGUID($gid))
    {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $rg = $c->model('ReleaseGroup')->get_by_gid($gid);
    unless ($rg) {
        $c->detach('not_found');
    }
    $c->model('ReleaseGroupType')->load($rg);

    my $opts = {};
    if ($c->stash->{inc}->artist)
    {
        $c->model('ArtistCredit')->load($rg);

        # make sure sort_name is loaded if there is only one artist.
        $c->model('Artist')->load($rg->artist_credit->names->[0])
            if (@{$rg->artist_credit->names} == 1);
    }

    if ($c->stash->{inc}->releases)
    {
        $opts->{releases} = $self->_load_paged($c, sub {
            $c->model('Release')->find_by_release_group($rg->id, shift, shift);
        });

        # make sure the release group is hooked up to the release, so
        # the serializer can get the release type from the release group.
        map { $_->release_group($rg) } @{$opts->{releases}};

        $c->model('ReleaseStatus')->load(@{$opts->{releases}});
        $c->model('Language')->load(@{$opts->{releases}});
        $c->model('Script')->load(@{$opts->{releases}});
        $c->model('Medium')->load_for_releases(@{$opts->{releases}});
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('release-group', $rg, $c->stash->{inc}, $opts));
}

sub release_group_search : Chained('root') PathPart('release-group') Args(0)
{
    my ($self, $c) = @_;

    my $result = xml_search('release-group', $c->stash->{args});
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    if (exists $result->{xml})
    {
        $c->res->body($result->{xml});
    }
    else
    {
        $c->res->status($result->{code});
        $c->res->body($c->stash->{serializer}->output_error($result->{error}));
    }
}

sub default : Path
{
    my ($self, $c, $resource) = @_;

    $c->stash->{serializer} = $serializers{$self->get_default_serialization_type}->new();
    $c->stash->{error} = "Invalid resource: $resource. ";
    $c->detach('bad_req');
}

no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
