package MusicBrainz::Server::Controller::WS::js;

use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller'; }

use Data::OptList;
use Encode qw( decode encode );
use List::UtilsBy qw( uniq_by );
use MusicBrainz::Server::WebService::JSONSerializer;
use MusicBrainz::Server::WebService::Validator;
use MusicBrainz::Server::Filters;
use MusicBrainz::Server::Data::Search qw( escape_query alias_query );
use MusicBrainz::Server::Data::Utils qw(
    artist_credit_to_ref
    hash_structure
);
use MusicBrainz::Server::Track qw( format_track_length );
use Readonly;
use Text::Trim;

# This defines what options are acceptable for WS calls
my $ws_defs = Data::OptList::mkopt([
    "tracklist" => {
        method => 'GET',
        optional => [ qw(q artist tracks limit page timestamp) ]
    },
    "cdstub" => {
        method => 'GET',
        optional => [ qw(q artist tracks limit page timestamp) ]
    },
    "freedb" => {
        method => 'GET',
        optional => [ qw(q artist tracks limit page timestamp) ]
    },
    "associations" => {
        method => 'GET',
    }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
     version => 'js',
     default_serialization_type => 'json',
};

Readonly my %serializers => (
    json => 'MusicBrainz::Server::WebService::JSONSerializer',
);

sub bad_req : Private
{
    my ($self, $c) = @_;
    $c->res->status(400);
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->output_error($c->stash->{error}));
}

sub begin : Private
{
}

sub end : Private
{
}

sub root : Chained('/') PathPart("ws/js") CaptureArgs(0)
{
    my ($self, $c) = @_;
    $self->validate($c, \%serializers) or $c->detach('bad_req');
}

sub tracklist : Chained('root') PathPart Args(1) {
    my ($self, $c, $id) = @_;

    my $tracklist = $c->model('Tracklist')->get_by_id($id);
    $c->model('Track')->load_for_tracklists($tracklist);
    $c->model('ArtistCredit')->load($tracklist->all_tracks);
    $c->model('Artist')->load(map { @{ $_->artist_credit->names } }
        $tracklist->all_tracks);

    my $ret = { toc => "" };
    $ret->{tracks} = [ map {
        length => format_track_length($_->length),
        name => $_->name,
        artist_credit => artist_credit_to_ref ($_->artist_credit),
    }, sort { $a->position <=> $b->position }
    $tracklist->all_tracks ];

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('generic', $ret));
}

sub freedb : Chained('root') PathPart Args(2) {
    my ($self, $c, $category, $id) = @_;

    my $response = $c->model ('FreeDB')->lookup ($category, $id);

    my $ret = { toc => "" };
    $ret->{tracks} = [ map {
        {
            name => $_->{title},
            artist => $_->{artist},
            length => format_track_length($_->{length}),
        }
    } @{ $response->tracks } ];

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('generic', $ret));
};

sub cdstub : Chained('root') PathPart Args(1) {
    my ($self, $c, $id) = @_;

    my $cdstub_toc = $c->model('CDStubTOC')->get_by_discid($id);
    my $ret = {
        toc => "",
        tracks => []
    };

    if ($cdstub_toc)
    {
        $c->model('CDStub')->load ($cdstub_toc);
        $c->model('CDStubTrack')->load_for_cdstub ($cdstub_toc->cdstub);
        $cdstub_toc->update_track_lengths;

        $ret->{toc} = $cdstub_toc->toc;
        $ret->{tracks} = [ map {
            {
                name => $_->title,
                length => format_track_length($_->length),
            }
        } $cdstub_toc->cdstub->all_tracks ];
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('generic', $ret));
}

sub tracklist_results {
    my ($self, $c, $results) = @_;

    my @output;

    my @gids = map { $_->entity->gid } @$results;

    my @releases = values %{ $c->model ('Release')->get_by_gids (@gids) };
    $c->model ('Medium')->load_for_releases (@releases);
    $c->model ('MediumFormat')->load (map { $_->all_mediums } @releases);
    $c->model ('ArtistCredit')->load (@releases);

    for my $release ( @releases )
    {
        next unless $release;

        my $count = 0;
        for my $medium ($release->all_mediums)
        {
            $count += 1;

            push @output, {
                gid => $release->gid,
                name => $release->name,
                position => $count,
                format => $medium->format_name,
                medium => $medium->name,
                comment => $release->comment,
                artist => $release->artist_credit->name,
                tracklist_id => $medium->tracklist_id,
            };
        }
    }

    return uniq_by { $_->{tracklist_id} } @output;
};

sub disc_results {
    my ($self, $type, $results) = @_;

    my @output;
    for (@$results)
    {
        my %result = (
            discid => $_->entity->discid,
            name => $_->entity->title,
            artist => $_->entity->artist,
        );

        $result{year} = $_->entity->year if $type eq 'freedb';
        $result{category} = $_->entity->category if $type eq 'freedb';

        $result{comment} = $_->entity->comment if $type eq 'cdstub';
        $result{barcode} = $_->entity->barcode if $type eq 'cdstub';

        push @output, \%result;
    }

    return @output;
};

sub disc_search {
    my ($self, $c, $type) = @_;

    my $query = escape_query (trim $c->stash->{args}->{q});
    my $artist = escape_query ($c->stash->{args}->{artist});
    my $tracks = escape_query ($c->stash->{args}->{tracks});
    my $limit = $c->stash->{args}->{limit} || 10;
    my $page = $c->stash->{args}->{page} || 1;

    # FIXME Should be able to remove the 'OR' when Lucene 4.0 comes out
    my $title = $type eq 'release' ? "release:($query*) OR release:($query)" : "$query* OR $query";
    my @query;

    push @query, $title if $query;
    push @query, "artist:($artist)" if $artist;
    push @query, "tracks:($tracks)" if $tracks;

    $query = join (" AND ", @query);

    my $no_redirect = 1;
    my $response = $c->model ('Search')->external_search (
        $type, $query, $limit, $page, 1, undef);

    my @output;

    if ($response->{pager})
    {
        my $pager = $response->{pager};

        @output = $type eq 'release' ?
            $self->tracklist_results ($c, $response->{results}) :
            $self->disc_results ($type, $response->{results});

        push @output, {
            pages => $pager->last_page,
            current => $pager->current_page
        };
    }
    else
    {
        # If an error occurred just ignore it for now and return an
        # empty list.  The javascript code for autocomplete doesn't
        # have any way to gracefully report or deal with
        # errors. --warp.
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('generic', \@output));
};

sub tracklist_search : Chained('root') PathPart('tracklist') Args(0) {
    my ($self, $c) = @_;

    return $self->disc_search ($c, 'release');
}

sub cdstub_search : Chained('root') PathPart('cdstub') Args(0) {
    my ($self, $c) = @_;

    return $self->disc_search ($c, 'cdstub');
};

sub freedb_search : Chained('root') PathPart('freedb') Args(0) {
    my ($self, $c) = @_;

    return $self->disc_search ($c, 'freedb');
};


# recording associations
sub associations : Chained('root') PathPart Args(1) {
    my ($self, $c, $id) = @_;

    my $tracklist = $c->model('Tracklist')->get_by_id($id);
    $c->model('Track')->load_for_tracklists($tracklist);
    $c->model('ArtistCredit')->load($tracklist->all_tracks);
    $c->model('Artist')->load(map { @{ $_->artist_credit->names } }
        $tracklist->all_tracks);

    $c->model('Recording')->load ($tracklist->all_tracks);

    my %appears_on = $c->model('Recording')->appears_on (
        [ map { $_->recording } $tracklist->all_tracks ], 3);

    my @structure;
    for (sort { $a->position <=> $b->position } $tracklist->all_tracks)
    {
        my $track = {
            name => $_->name,
            length => format_track_length($_->length),
            artist_credit => artist_credit_to_ref ($_->artist_credit),
        };

        my $data = {
            length => format_track_length($_->length),
            name => $_->name,
            artist_credit => { preview => $_->artist_credit->name },
            edit_sha1 => hash_structure ($track)
        };

        $data->{recording} = {
            gid => $_->recording->gid,
            name => $_->recording->name,
            comment => $_->recording->comment,
            length => format_track_length($_->recording->length),
            artist_credit => { preview => $_->artist_credit->name },
            appears_on => {
                hits => $appears_on{$_->recording->id}{hits},
                results => [ map { {
                    'name' => $_->name,
                    'gid' => $_->gid
                    } } @{ $appears_on{$_->recording->id}{results} } ],
            }
        };

        push @structure, $data;
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('generic', \@structure));
}

sub default : Path
{
    my ($self, $c, $resource) = @_;

    $c->stash->{serializer} = $serializers{$self->get_default_serialization_type}->new();
    $c->stash->{error} = "Invalid resource: $resource";
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
