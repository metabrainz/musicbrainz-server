package MusicBrainz::Server::Controller::WS::2;

# TODO: Add rate-limiting code
# TODO: Add paging 

use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Validation;
use MusicBrainz::Server::WebService::XMLSerializer;
use MusicBrainz::Server::WebService::XMLSearch qw( xml_search );
use MusicBrainz::Server::WebService::Validator;
use Readonly;
use Data::OptList;

Readonly our $MAX_ITEMS => 25;

# This defines what options are acceptable for WS calls
# rel_status and rg_type are special cases that allow for one release status and one release group
# type per call to be specified.
my $ws_defs = Data::OptList::mkopt([
     artist => { 
                         method   => 'GET',
                         required => [ qw(name) ],
                         optional => [ qw(limit offset) ]
     },
     artist => { 
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(limit offset) ]
     },
     artist => { 
                         method   => 'GET',
                         inc      => [ qw( aliases labels rel_status rg_type) ],
     },
     "release-group" => { 
                         method   => 'GET',
                         required => [ qw(name) ],
                         optional => [ qw(limit offset) ]
     },
     "release-group" => { 
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(limit offset) ]
     },
     "release-group" => { 
                         method   => 'GET',
                         inc      => [ qw( artists releases ) ],
     },
     release => { 
                         method   => 'GET',
                         required => [ qw(name) ],
                         optional => [ qw(limit offset) ]
     },
     release => { 
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(limit offset) ]
     },
     release => { 
                         method   => 'GET',
                         inc      => [ qw(artists recordings releasegroups labels
                                     )] 
     },
     recording => { 
                         method   => 'GET',
                         required => [ qw(name) ],
                         optional => [ qw(limit offset) ]
     },
     recording => { 
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(limit offset) ]
     },
     recording => { 
                         method   => 'GET',
                         inc      => [ qw( artists releases  
                                     )] 
     },
     label => { 
                         method   => 'GET',
                         required => [ qw(name) ],
                         optional => [ qw(limit offset) ]
     },
     label => { 
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(limit offset) ]
     },
     label => { 
                         method   => 'GET',
                         inc      => [ qw( aliases 
                                     ) ], 
     },
     work => { 
                         method   => 'GET',
                         required => [ qw(name) ],
                         optional => [ qw(limit offset) ]
     },
     work => { 
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(limit offset) ]
     },
     work => { 
                         method   => 'GET',
                         inc      => [ qw( artists  
                                     )]
     },
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
    }

    my $artist = $c->model('Artist')->get_by_gid($gid);
    unless ($artist) {
        $c->detach('not_found');
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

    if ($c->stash->{inc}->labels)
    {
         my @labels = $c->model('Label')->find_by_artist($artist->id);
         $opts->{labels} = \@labels;
    }

#    if ($c->stash->{inc}->has_rels)
#    {
#        my $types = $c->stash->{inc}->get_rel_types();
#        my @rels = $c->model('Relationship')->load_subset($types, $artist);
#        $opts->{rels} = $artist->relationships;
#    }

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
    $c->model('ArtistCredit')->load($rg)
        if ($c->stash->{inc}->artists);

    my $opts = {};
    if ($c->stash->{inc}->releases)
    {
        $opts->{releases} = $self->_load_paged($c, sub {
            $c->model('Release')->find_by_release_group($rg->id, $MAX_ITEMS, 0);
        });
    }
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('release-group', $rg, $c->stash->{inc}, $opts));
}

sub release_group_search : Chained('root') PathPart('release-group') Args(0)
{
    my ($self, $c) = @_;

    my $result = xml_search('release-group', $c->stash->{args});
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

sub release: Chained('root') PathPart('release') Args(1)
{
    my ($self, $c, $gid) = @_;

    if (!MusicBrainz::Server::Validation::IsGUID($gid))
    {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $release = $c->model('Release')->get_by_gid($gid);
    unless ($release) {
        $c->detach('not_found');
    }
    $c->model('ReleaseStatus')->load($release);
    $c->model('Language')->load($release);
    $c->model('Script')->load($release);
    $c->model('Country')->load($release);
    $c->model('ArtistCredit')->load($release)
        if ($c->stash->{inc}->artists);
    $c->model('Release')->load_meta($release);

    if ($c->stash->{inc}->releasegroups)
    {
         $c->model('ReleaseGroup')->load($release);
         $c->model('ReleaseGroupType')->load($release->release_group);
    }

    if ($c->stash->{inc}->labels)
    {
         $c->model('ReleaseLabel')->load($release); 
         $c->model('Label')->load($release->all_labels)
    }

    if ($c->stash->{inc}->recordings)
    {
        $c->model('Medium')->load_for_releases($release);
        my @mediums = $release->all_mediums;
        $c->model('MediumFormat')->load(@mediums);

        my @tracklists = grep { defined } map { $_->tracklist } @mediums;
        $c->model('Track')->load_for_tracklists(@tracklists);

        my @tracks = map { $_->all_tracks } @tracklists;
        my @recordings = $c->model('Recording')->load(@tracks);
        $c->model('Recording')->load_meta(@recordings);
    }

    my $opts = {};
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('release', $release, $c->stash->{inc}, $opts));
}

sub release_search : Chained('root') PathPart('release') Args(0)
{
    my ($self, $c) = @_;

    my $result = xml_search('release', $c->stash->{args});
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

sub recording: Chained('root') PathPart('recording') Args(1)
{
    my ($self, $c, $gid) = @_;

    if (!MusicBrainz::Server::Validation::IsGUID($gid))
    {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $recording = $c->model('Recording')->get_by_gid($gid);
    unless ($recording) {
        $c->detach('not_found');
    }
    $c->model('ArtistCredit')->load($recording)
        if ($c->stash->{inc}->artists);

    my $opts = {};
    if ($c->stash->{inc}->releases)
    {
        my @releases = $c->model('Release')->find_by_recording($recording->id, $MAX_ITEMS, 0);
        $opts->{releases} = \@releases;
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('recording', $recording, $c->stash->{inc}, $opts));
}

sub recording_search : Chained('root') PathPart('recording') Args(0)
{
    my ($self, $c) = @_;

    my $result = xml_search('recording', $c->stash->{args});
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

sub label : Chained('root') PathPart('label') Args(1)
{
    my ($self, $c, $gid) = @_;

    if (!MusicBrainz::Server::Validation::IsGUID($gid))
    {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $label = $c->model('Label')->get_by_gid($gid);
    unless ($label) {
        $c->detach('not_found');
    }

    my $opts = {};
    $opts->{aliases} = $c->model('Label')->alias->find_by_entity_id($label->id) 
        if ($c->stash->{inc}->aliases);

    $c->model('LabelType')->load($label);
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('label', $label, $c->stash->{inc}, $opts));
}

sub label_search : Chained('root') PathPart('label') Args(0)
{
    my ($self, $c) = @_;

    my $result = xml_search('label', $c->stash->{args});
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

sub work : Chained('root') PathPart('work') Args(1)
{
    my ($self, $c, $gid) = @_;

    if (!MusicBrainz::Server::Validation::IsGUID($gid))
    {
        $c->stash->{error} = "Invalid mbid.";
        $c->detach('bad_req');
    }

    my $work = $c->model('Work')->get_by_gid($gid);
    unless ($work) {
        $c->detach('not_found');
    }

    my $opts = {};

    $c->model('WorkType')->load($work);
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('work', $work, $c->stash->{inc}, $opts));
}

sub work_search : Chained('root') PathPart('work') Args(0)
{
    my ($self, $c) = @_;

    my $result = xml_search('work', $c->stash->{args});
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
