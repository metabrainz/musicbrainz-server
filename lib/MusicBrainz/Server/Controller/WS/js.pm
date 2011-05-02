package MusicBrainz::Server::Controller::WS::js;

use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::WebService::JSONSerializer;
use MusicBrainz::Server::WebService::Validator;
use MusicBrainz::Server::Filters;
use MusicBrainz::Server::Data::Search qw( escape_query alias_query );
use MusicBrainz::Server::Data::Utils qw(
    artist_credit_to_ref
    hash_structure
    type_to_model
);
use MusicBrainz::Server::Track qw( format_track_length );
use Readonly;
use Text::Trim;
use Text::Unaccent qw( unac_string_utf16 );
use Data::OptList;
use Encode qw( decode encode );

# This defines what options are acceptable for WS calls
my $ws_defs = Data::OptList::mkopt([
    "artist" => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(direct limit page timestamp) ]
    },
    "label" => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(direct limit page timestamp) ]
    },
    "recording" => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(a r direct limit page timestamp) ]
    },
    "release-group" => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(r direct limit page timestamp) ]
    },
    "release" => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(r direct limit page timestamp) ]
    },
    "work" => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(r direct limit page timestamp) ]
    },
    "tracklist" => {
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

sub _autocomplete_entity {
    my ($self, $c, $type) = @_;

    my $query = trim $c->stash->{args}->{q};
    my $limit = $c->stash->{args}->{limit} || 10;
    my $page = $c->stash->{args}->{page} || 1;
    my $direct = $c->stash->{args}->{direct};

    unless ($query) {
        $c->detach('bad_req');
    }

    if ($direct eq 'true')
    {
        $self->_autocomplete_direct ($c, $type, $query, $page, $limit);
    }
    else
    {
        $self->_autocomplete_indexed($c, $type, $query, $page, $limit);
    }
}

sub _autocomplete_direct {
    my ($self, $c, $type, $query, $page, $limit) = @_;

    my $offset = ($page - 1) * $limit;  # page is not zero based.

    my ($search_results, $hits) = $c->model ('Search')->search (
        $type, $query, $limit, $offset);

    my @output;

    for (@$search_results)
    {
        my $entity = $_->entity;

        my $item = {
            name => $entity->name,
            id => $entity->id,
            gid => $entity->gid,
            comment => $entity->comment,
        };

        if ($entity->meta->has_attribute ('sort_name'))
        {
            $item->{sortname} = $entity->sort_name;
        }

        push @output, $item;
    }

    my $pager = Data::Page->new ();
    $pager->entries_per_page ($limit);
    $pager->current_page ($page);
    $pager->total_entries ($hits);

    push @output, {
        pages => $pager->last_page,
        current => $pager->current_page
    };

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('generic', \@output));
}

sub _autocomplete_indexed {
    my ($self, $c, $type, $query, $page, $limit) = @_;

    $query = decode ("utf-16", unac_string_utf16 (encode ("utf-16", $query)));
    $query = escape_query ($query);
    $query = $query.'*';

    if (grep ($type eq $_, 'artist', 'label', 'work'))
    {
        $query = alias_query ($type, $query);
    }

    my $model = type_to_model ($type);

    my $no_redirect = 1;
    my $response = $c->model ('Search')->external_search (
        $c, $type, $query, $limit, $page, 1, undef, $no_redirect);

    my @output;

    if ($response->{pager})
    {
        my $pager = $response->{pager};

        for my $result (@{ $response->{results} })
        {
            my $entity = $c->model($model)->get_by_gid ($result->{entity}->gid);

            next unless $entity;

            my $item = {
                name => $result->{entity}->name,
                id => $entity->id,
                gid => $result->{entity}->gid,
                comment => $result->{entity}->comment,
            };

            if ($entity->meta->has_attribute ('sort_name'))
            {
                $item->{sortname} = $entity->sort_name;
            }

            push @output, $item;
        }

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

        push @output, { pages => 1, current => 1 };
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('generic', \@output));
}

sub artist : Chained('root') PathPart('artist') Args(0)
{
    my ($self, $c) = @_;

    $self->_autocomplete_entity($c, 'artist');
}

sub label : Chained('root') PathPart('label') Args(0)
{
    my ($self, $c) = @_;

    $self->_autocomplete_entity($c, 'label');
}

sub release_group : Chained('root') PathPart('release-group') Args(0)
{
    my ($self, $c) = @_;

    $self->_autocomplete_entity($c, 'release_group');
}

sub release : Chained('root') PathPart('release') Args(0)
{
    my ($self, $c) = @_;

    $self->_autocomplete_entity($c, 'release');
}

sub work : Chained('root') PathPart('work') Args(0)
{
    my ($self, $c) = @_;

    $self->_autocomplete_entity($c, 'work');
}

sub recording : Chained('root') PathPart('recording') Args(0)
{
    my ($self, $c) = @_;

    my $query = trim $c->stash->{args}->{q};
    my $artist = $c->stash->{args}->{a} || '';
    my $limit = $c->stash->{args}->{limit} || 10;
    my $page = $c->stash->{args}->{page} || 1;
    my $direct = $c->stash->{args}->{direct};

    unless ($query) {
        $c->detach('bad_req');
    }

    if ($direct eq 'true')
    {
        $self->_recording_direct($c, $query, $artist, $page, $limit);
    }
    else
    {
        $self->_recording_indexed($c, $query, $artist, $page, $limit);
    }
}

sub _recording_direct {
    my ($self, $c, $query, $artist, $page, $limit) = @_;

    my $offset = ($page - 1) * $limit;  # page is not zero based.

    my $where = {};
    $where->{artist} = $artist if $artist;

    my ($search_results, $hits) = $c->model ('Search')->search (
        'recording', $query, $limit, $offset, $where);

    my @entities = map { $_->entity } @$search_results;

    $c->model ('ArtistCredit')->load (@entities);
    $c->model('ISRC')->load_for_recordings (@entities);

    my %appears_on = $c->model('Recording')->appears_on (\@entities, 3);

    my @output = map {
        {
            recording => $_,
            appears_on => $appears_on{$_->id}
        }
    } @entities;

    my $pager = Data::Page->new ();
    $pager->entries_per_page ($limit);
    $pager->current_page ($page);
    $pager->total_entries ($hits);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('autocomplete_recording', \@output, $pager));
}

sub _recording_indexed {
    my ($self, $c, $query, $artist, $page, $limit) = @_;

    $query = decode ("utf-16", unac_string_utf16 (encode ("utf-16", $query)));
    $query = escape_query ($query);
    $artist = escape_query ($artist);

    my $lucene_query = "recording:($query*)";
    $lucene_query .= " AND artist:($artist)" if $artist;

    my $no_redirect = 1;
    my $response = $c->model ('Search')->external_search (
        $c, 'recording', $lucene_query, $limit, $page, 1, undef, $no_redirect);

    my @output;
    my $pager;

    if ($response->{pager})
    {
        $pager = $response->{pager};

        my @entities;

        for my $result (@{ $response->{results} })
        {
            my $entity = $c->model('Recording')->get_by_gid ($result->{entity}->gid);

            next unless $entity;

            $c->model('ISRC')->load_for_recordings ($entity);

            $entity->artist_credit ($result->{entity}->artist_credit);

            push @entities, $entity;
        }

        my %appears_on = $c->model('Recording')->appears_on (\@entities, 3);

        @output = map {
            {
                recording => $_,
                appears_on => $appears_on{$_->id}
            }
        } @entities;
    }
    else
    {
        # If an error occurred just ignore it for now and return an
        # empty list.  The javascript code for autocomplete doesn't
        # have any way to gracefully report or deal with
        # errors. --warp.

        $pager = Data::Page->new ();
        $pager->entries_per_page ($limit);
        $pager->current_page ($page);
        $pager->total_entries (0);
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('autocomplete_recording', \@output, $pager));
}

sub tracklist : Chained('root') PathPart Args(1) {
    my ($self, $c, $id) = @_;

    my $tracklist = $c->model('Tracklist')->get_by_id($id);
    $c->model('Track')->load_for_tracklists($tracklist);
    $c->model('ArtistCredit')->load($tracklist->all_tracks);
    $c->model('Artist')->load(map { @{ $_->artist_credit->names } }
        $tracklist->all_tracks);

    my $structure = [ map {
        length => format_track_length($_->length),
        name => $_->name,
        artist_credit => artist_credit_to_ref ($_->artist_credit),
    }, sort { $a->position <=> $b->position }
    $tracklist->all_tracks ];

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('generic', $structure));
}

sub tracklist_search : Chained('root') PathPart('tracklist') Args(0) {
    my ($self, $c) = @_;

    my $query = escape_query (trim $c->stash->{args}->{q});
    my $artist = escape_query ($c->stash->{args}->{artist});
    my $tracks = escape_query ($c->stash->{args}->{tracks});
    my $limit = $c->stash->{args}->{limit} || 10;
    my $page = $c->stash->{args}->{page} || 1;

    unless ($query) {
        $c->detach('bad_req');
    }

    $query = "release:($query*)";
    $query .= " AND artist:($artist)" if $artist;
    $query .= " AND tracks:($tracks)" if $tracks;

    my $no_redirect = 1;
    my $response = $c->model ('Search')->external_search (
        $c, 'release', $query, $limit, $page, 1, undef, $no_redirect);

    my @output;

    if ($response->{pager})
    {
        my $pager = $response->{pager};

        my @gids = map { $_->{entity}->gid } @{ $response->{results} };

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
}

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
