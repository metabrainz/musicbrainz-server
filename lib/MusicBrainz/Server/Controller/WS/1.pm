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
    artist => {
        method   => 'GET',
        inc      => [ qw(aliases release-groups _rel_status _rg_type counts release-events discs labels  _relations) ],
    },
    label => {
        method   => 'GET',
        inc      => [ qw(aliases  _relations) ],
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

    my $opts = {};
    $opts->{aliases} = $c->model('Artist')->alias->find_by_entity_id($artist->id)
        if ($c->stash->{inc}->aliases);

    if ($c->stash->{inc}->rg_type)
    {
        my @rg;

        if ($c->stash->{inc}->various_artists)
        {
            @rg = $c->model('ReleaseGroup')->filter_by_track_artist($artist->id, $c->stash->{inc}->rg_type);
        }
        else
        {
            @rg = $c->model('ReleaseGroup')->filter_by_artist($artist->id, $c->stash->{inc}->rg_type);
        }

        $c->model('ArtistCredit')->load(@rg);
        $c->model('ReleaseGroupType')->load(@rg);
        $opts->{release_groups} = \@rg;

        if (@rg)
        {
            my ($results, $hits) = $self->_load_paged($c, sub {
                $c->model('Release')->find_by_release_group([ map { $_->id } @rg ], shift, shift)
            });

            $c->model('ReleaseStatus')->load(@$results);

            my @releases;
            if ($c->stash->{inc}->rel_status && @rg)
            {
                @releases = grep { $_->status->id == $c->stash->{inc}->rel_status } @$results;
            }
            else
            {
                @releases = @$results;
            }

            # make sure the release groups are hooked up to the releases, so
            # the serializer can get the release type from the release group.
            my %rel_to_rg_map = map { ( $_->id => $_ ) } @rg;
            map { $_->release_group($rel_to_rg_map{$_->release_group_id}) } @releases;

            if ($c->stash->{inc}->discs)
            {
                $c->model('Medium')->load_for_releases(@releases);
                my @medium_cdtocs = $c->model('MediumCDTOC')->load_for_mediums(map { $_->all_mediums } @releases);
                $c->model('CDTOC')->load(@medium_cdtocs);
            }

            $c->model('ReleaseStatus')->load(@releases);
            $c->model('Language')->load(@releases);
            $c->model('Script')->load(@releases);

            $c->model('Relationship')->load_subset([ 'url' ], @releases);
            $c->stash->{inc}->asin(1);

            $c->stash->{inc}->releases(1);
            $opts->{releases} = \@releases;
        }
    }

    if ($c->stash->{inc}->labels)
    {
         my @labels = $c->model('Label')->find_by_artist($artist->id);
         $opts->{labels} = \@labels;
    }

     if ($c->stash->{inc}->has_rels)
     {
         my $types = $c->stash->{inc}->get_rel_types;
         my @rels = $c->model('Relationship')->load_subset($types, $artist);
     }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('artist', $artist, $c->stash->{inc}, $opts));
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

    if ($c->stash->{inc}->has_rels)
    {
        my $types = $c->stash->{inc}->get_rel_types();
        my @rels = $c->model('Relationship')->load_subset($types, $label);
        $opts->{rels} = $label->relationships;

        # load the artist type, as /ws/1 always included that for artists.
        my @artists = grep { $_->target_type eq 'artist' } @{$opts->{rels}};
        $c->model('ArtistType')->load(map { $_->target } @artists);

        # load the label country and type, as /ws/1 always included that for labels.
        my @labels = grep { $_->target_type eq 'label' } @{$opts->{rels}};
        $c->model('Country')->load(map { $_->target } @labels);
        $c->model('LabelType')->load(map { $_->target } @labels);

        my @releases = grep { $_->target_type eq 'release' } @{$opts->{rels}};
        for (@releases)
        {
            $_->target->release_group (
                $c->model('ReleaseGroup')->get_by_id($_->target->release_group_id));
        }
        $c->model('ReleaseStatus')->load(map { $_->target } @releases);
        $c->model('ReleaseGroupType')->load(map { $_->target->release_group } @releases);
        $c->model('Script')->load(map { $_->target } @releases);
        $c->model('Language')->load(map { $_->target } @releases);
    }

    $c->model('Country')->load($label);
    $c->model('LabelType')->load($label);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('label', $label, $c->stash->{inc}, $opts));
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
