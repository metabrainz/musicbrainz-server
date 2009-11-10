package MusicBrainz::Server::Controller::WS::2;

# TODO: Add rate-limiting code

use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Validation;
use MusicBrainz::Server::WebService::XMLSerializer;
use MusicBrainz::Server::WebService::XMLSearch qw( xml_search );
use MusicBrainz::Server::WebService::Validator;
use Readonly;
use Data::OptList;

# This defines what options are acceptable for WS calls -- currently only artist calls are defined.
# rel_status and rg_type are special cases that allow for one release status and one release group
# type per call to be specified.
my $ws_defs = Data::OptList::mkopt([
     artist => { 
                 method   => 'GET',
                 inc      => [ qw( aliases artist-rels label-rels release-rels track-rels url-rels 
                                   tags ratings user-tags user-ratings release-events discs labels 
                                   rel_status rg_type
                            ) ],
     },
     artist => { 
                 method   => 'GET',
                 required => [ qw(name) ],
                 optional => [ qw(limit offset) ]
     },
     artist => { 
                 method   => 'GET',
                 required => [ qw(query) ],
                 optional => [ qw(limit offset) ]
     }
]);

with 'MusicBrainz::Server::WebService::Validator' => 
{
     defs => $ws_defs
};

Readonly my %serializers => (
    xml => 'MusicBrainz::Server::WebService::XMLSerializer',
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

sub root : Chained('/') PathPart("ws/2") CaptureArgs(0) 
{
    my ($self, $c) = @_;
    $self->validate($c, \%serializers) or $c->detach('bad_req');
}

sub artist : Chained('root') PathPart('artist') Args(1)
{
    my ($self, $c, $gid) = @_;

    if (!MusicBrainz::Server::Validation::IsGUID($gid))
    {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
        return 0;
    }

    my $artist = $c->model('Artist')->get_by_gid($gid);
    unless ($artist) {
        $c->detach('not_found');
        return 0;
    }

    $c->model('ArtistType')->load($artist);
    $c->model('Gender')->load($artist);
    $c->model('Country')->load($artist);

    my $opts = {};
    $opts->{aliases} = $c->model('Artist')->alias->find_by_entity_id($artist->id) 
        if ($c->stash->{inc}->aliases);
    if ($c->stash->{inc}->rg_type)
    {
         my @rg = $c->model('ReleaseGroup')->filter_by_artist($artist->id, $c->stash->{inc}->rg_type);
         $c->model('ArtistCredit')->load(@rg);
         $c->model('ReleaseGroupType')->load(@rg);
         $opts->{release_groups} = \@rg;
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('artist', $artist, $c->stash->{inc}, $opts));
}

sub artist_search : Chained('root') PathPart('artist') Args(0)
{
    my ($self, $c) = @_;

    my $result = xml_search('artist', $c->stash->{args});
    if (exists $result->{xml})
    {
        $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
        $c->res->body($result->{xml});
    }
    else
    {
        $c->res->status($result->{code});
        $c->res->content_type("text/plain; charset=utf-8");
        $c->res->body($result->{error}."\nFor usage, please see: http://musicbrainz.org/development/mmd\015\012");
    }
}

# Incomplete -- DO NOT REVIEW PAST HERE
sub label : Path('label')
{
    my ($self, $c, $gid) = @_;

    $c->stash->{gid} = $gid;
    $c->forward('check_entity');

    my $label = $c->model('Label')->get_by_gid($gid);
    unless ($label) {
        $c->detach('not_found');
        return 0;
    }

    $c->model('LabelType')->load($label);
    $c->model('Country')->load($label);

    my $serializer = $serializers{$c->req->params->{type}}->new();
    $c->res->content_type($serializer->mime_type . '; charset=utf-8');
    $c->res->body($serializer->serialize('label', $label));
}

sub work : Path('work')
{
    my ($self, $c, $gid) = @_;

    $c->stash->{gid} = $gid;
    $c->forward('check_entity');

    my $work = $c->model('Work')->get_by_gid($gid);
    unless ($work) {
        $c->detach('not_found');
        return 0;
    }

    $c->model('WorkType')->load($work);
    $c->model('ArtistCredit')->load($work);

    my $serializer = $serializers{$c->req->params->{type}}->new();
    $c->res->content_type($serializer->mime_type . '; charset=utf-8');
    $c->res->body($serializer->serialize('work', $work));
}

sub recording : Path('recording')
{
    my ($self, $c, $gid) = @_;

    $c->stash->{gid} = $gid;
    $c->forward('check_entity');

    my $recording = $c->model('Recording')->get_by_gid($gid);
    unless ($recording) {
        $c->detach('not_found');
        return 0;
    }

    $c->model('ArtistCredit')->load($recording);

    my $serializer = $serializers{$c->req->params->{type}}->new();
    $c->res->content_type($serializer->mime_type . '; charset=utf-8');
    $c->res->body($serializer->serialize('recording', $recording));
}

sub release_group : Path('release-group')
{
    my ($self, $c, $gid) = @_;

    $c->stash->{gid} = $gid;
    $c->forward('check_entity');

    my $release_group = $c->model('ReleaseGroup')->get_by_gid($gid);
    unless ($release_group) {
        $c->detach('not_found');
        return 0;
    }

    $c->model('ReleaseGroupType')->load($release_group);
    $c->model('ArtistCredit')->load($release_group);

    my $serializer = $serializers{$c->req->params->{type}}->new();
    $c->res->content_type($serializer->mime_type . '; charset=utf-8');
    $c->res->body($serializer->serialize('release_group', $release_group));
}

sub release : Path('release')
{
    my ($self, $c, $gid) = @_;

    $c->stash->{gid} = $gid;
    $c->forward('check_entity');

    my $release = $c->model('Release')->get_by_gid($gid);
    unless ($release) {
        $c->detach('not_found');
        return 0;
    }

    $c->model('ReleaseStatus')->load($release);
    $c->model('ReleasePackaging')->load($release);
    $c->model('Country')->load($release);
    $c->model('ArtistCredit')->load($release);

    my $serializer = $serializers{$c->req->params->{type}}->new();
    $c->res->content_type($serializer->mime_type . '; charset=utf-8');
    $c->res->body($serializer->serialize('release', $release));
}

no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2009 Robert Kaye

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
