package MusicBrainz::Server::Controller::WS::js;

use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js'; }

use Data::OptList;
use JSON qw( encode_json decode_json );
use List::UtilsBy qw( uniq_by );
use MusicBrainz::Server::WebService::Validator;
use MusicBrainz::Server::Filters;
use MusicBrainz::Server::Data::Search qw( escape_query );
use MusicBrainz::Server::Constants qw( entities_with %ENTITIES );
use MusicBrainz::Server::Validation qw( is_guid );
use Readonly;
use Scalar::Util qw( blessed );
use Text::Trim;
use Time::Piece;

# This defines what options are acceptable for WS calls
my $ws_defs = Data::OptList::mkopt([
    "medium" => {
        method => 'GET',
        inc => [ qw(recordings rels) ],
        optional => [ qw(q artist tracks limit page timestamp) ]
    },
    "cdstub" => {
        method => 'GET',
        optional => [ qw(q artist tracks limit page timestamp) ]
    },
    "cover-art-upload" => {
        method => 'GET',
    },
    "entity" => {
        method => 'GET',
        inc => [ qw(rels) ]
    },
    "events" => {
        method => 'GET'
    },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
     version => 'js',
};

sub medium : Chained('root') PathPart Args(1) {
    my ($self, $c, $id) = @_;

    my $medium = $c->model('Medium')->get_by_id($id);

    unless ($medium) {
        $c->stash->{error} = 'No medium found with this ID.';
        $c->detach('bad_req');
    }

    $c->model('MediumFormat')->load($medium);
    $c->model('MediumCDTOC')->load_for_mediums($medium);
    $c->model('CDTOC')->load($medium->all_cdtocs);
    $c->model('Track')->load_for_mediums($medium);
    $c->model('ArtistCredit')->load($medium->all_tracks);
    $c->model('Artist')->load(map { @{ $_->artist_credit->names } }
                              $medium->all_tracks);

    if ($c->stash->{inc}->recordings) {
        $c->model('Recording')->load($medium->all_tracks);
        $c->model('ArtistCredit')->load(map $_->recording, $medium->all_tracks);

        if ($c->stash->{inc}->rels) {
            $c->model('Relationship')->load_cardinal(map { $_->recording } $medium->all_tracks);
        }
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body(encode_json($medium->TO_JSON));
}

sub cdstub : Chained('root') PathPart Args(1) {
    my ($self, $c, $id) = @_;

    my $cdstub = $c->model('CDStub')->get_by_discid($id);
    my $ret = {
        toc => "",
        tracks => []
    };

    if ($cdstub)
    {
        $c->model('CDStubTrack')->load_for_cdstub($cdstub);
        $cdstub->update_track_lengths;

        $ret->{toc} = $cdstub->toc;
        $ret->{tracks} = [ map {
            {
                name => $_->title,
                artist => $_->artist,
                length => $_->length,
                artist => $_->artist,
            }
        } $cdstub->all_tracks ];
    }

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body(encode_json($ret));
}

sub tracklist_results {
    my ($self, $c, $results) = @_;

    my @output;

    my @gids = map { $_->entity->gid } @$results;

    my @releases = values %{ $c->model('Release')->get_by_gids(@gids) };
    $c->model('Medium')->load_for_releases(@releases);
    $c->model('MediumFormat')->load(map { $_->all_mediums } @releases);
    $c->model('ArtistCredit')->load(@releases);

    for my $release ( @releases )
    {
        next unless $release;

        for my $medium ($release->all_mediums)
        {
            push @output, {
                gid => $release->gid,
                name => $release->name,
                position => $medium->position,
                format => $medium->format ? $medium->format->TO_JSON : undef,
                medium => $medium->name,
                comment => $release->comment,
                artist => $release->artist_credit->name,
                medium_id => $medium->id,
            };
        }
    }

    return uniq_by { $_->{medium_id} } @output;
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

        $result{comment} = $_->entity->comment if $type eq 'cdstub';
        $result{barcode} = $_->entity->barcode->format if $type eq 'cdstub';

        push @output, \%result;
    }

    return @output;
};

sub disc_search {
    my ($self, $c, $type) = @_;

    my $query = escape_query(trim $c->stash->{args}->{q});
    my $artist = escape_query($c->stash->{args}->{artist});
    my $tracks = escape_query($c->stash->{args}->{tracks});
    my $limit = $c->stash->{args}->{limit} || 10;
    my $page = $c->stash->{args}->{page} || 1;

    # FIXME Should be able to remove the 'OR' when Lucene 4.0 comes out
    my $title = $type eq 'release' ? "release:($query*) OR release:($query)" : "$query* OR $query";
    my @query;

    push @query, $title if $query;
    push @query, "artist:($artist)" if $artist;
    push @query, ($type eq 'release' ? "tracksmedium:($tracks)" : "tracks:($tracks)") if $tracks;

    $query = join(" AND ", @query);

    my $no_redirect = 1;
    my $response = $c->model('Search')->external_search($type, $query, $limit, $page, 1);
    my @output;

    if ($response->{pager})
    {
        my $pager = $response->{pager};

        @output = $type eq 'release' ?
            $self->tracklist_results($c, $response->{results}) :
            $self->disc_results($type, $response->{results});

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
    $c->res->body(encode_json(\@output));
};

sub medium_search : Chained('root') PathPart('medium') Args(0) {
    my ($self, $c) = @_;

    return $self->disc_search($c, 'release');
}

sub cdstub_search : Chained('root') PathPart('cdstub') Args(0) {
    my ($self, $c) = @_;

    return $self->disc_search($c, 'cdstub');
};

sub cover_art_upload : Chained('root') PathPart('cover-art-upload') Args(1)
{
    my ($self, $c, $gid) = @_;

    $self->check_login($c, 'not logged in');

    my $mime_type = $c->request->params->{mime_type};
    unless ($c->model('CoverArtArchive')->is_valid_mime_type($mime_type)) {
        $self->detach_with_error($c, 'invalid mime_type');
    }

    my $id = $c->request->params->{image_id} // $c->model('CoverArtArchive')->fresh_id;
    my $bucket = 'mbid-' . $gid;

    my %s3_policy;
    $s3_policy{mime_type} = $mime_type;
    $s3_policy{redirect} = $c->uri_for_action('/release/cover_art_uploaded', [ $gid ])->as_string()
        if $c->request->params->{redirect};

    my $expiration = gmtime() + 3600;
    $s3_policy{expiration} = $expiration->datetime . '.000Z';

    my $data = {
        action => DBDefs->COVER_ART_ARCHIVE_UPLOAD_PREFIXER($bucket),
        image_id => "$id",
        formdata => $c->model('CoverArtArchive')->post_fields($bucket, $gid, $id, \%s3_policy)
    };

    $c->res->headers->header( 'Cache-Control' => 'no-cache', 'Pragma' => 'no-cache' );
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body(encode_json($data));
}

sub entity : Chained('root') PathPart('entity') Args(1)
{
    my ($self, $c, $gid) = @_;

    unless (is_guid($gid)) {
        $c->stash->{error} = "$gid is not a valid MusicBrainz ID.";
        $c->detach('bad_req');
        return;
    }

    my $entity;
    my $type;

    for (entities_with(['mbid'], take => 'model')) {
        $type = $_;
        $entity = $c->model($type)->get_by_gid($gid);
        last if defined $entity;
    }

    unless (defined $entity) {
        $c->stash->{error} = "The requested entity was not found.";
        $c->detach('not_found');
        return;
    }

    my $data = $c->stash->{serializer}->serialize_internal($c, $entity);
    my $entity_properties = $ENTITIES{$type};
    if ($entity_properties->{mbid}{relatable}) {
        my $relationships = [map {$_->TO_JSON} $entity->all_relationships];
        $data->{relationships} = $relationships if @$relationships;
    };

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body(encode_json($data));
}

sub default : Path
{
    my ($self, $c, $resource) = @_;

    $c->stash->{serializer} = $self->get_serialization($c);
    $c->stash->{error} = "Invalid resource: $resource";
    $c->detach('bad_req');
}

sub events : Chained('root') PathPart('events') {
    my ($self, $c) = @_;

    my $events = $c->model('Statistics')->all_events;

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body(encode_json($events));
}

sub detach_with_error : Private {
    my ($self, $c, $error, $status) = @_;

    $c->res->content_type('application/json; charset=utf-8');
    $c->res->body(encode_json({
        error => (blessed($error) ? "$error" : $error),
    }));
    $c->res->status($status // 400);
    $c->detach;
}

sub critical_error : Private {
    my ($self, $c, $error, $status) = @_;

    $c->stash->{error_body_in_stash} = 1;
    $c->stash->{body} = encode_json({
        error => (blessed($error) ? "$error" : $error),
    });
    $c->stash->{status} = $status // 400;
    die $error;
}

sub get_json_request_body : Private {
    my ($self, $c) = @_;

    my $body = $c->req->body;
    $self->detach_with_error($c, 'empty request') unless $body;

    my $json_string = <$body>;
    my $decoded_object = eval { decode_json($json_string) };

    $self->detach_with_error($c, "$@") if $@;

    return $decoded_object;
}

sub check_login : Private {
    my ($self, $c, $error) = @_;

    $c->forward('/user/cookie_login') unless $c->user_exists;
    $self->detach_with_error($c, $error) unless $c->user_exists;
}

no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
