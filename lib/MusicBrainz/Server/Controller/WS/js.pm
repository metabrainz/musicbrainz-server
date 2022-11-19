package MusicBrainz::Server::Controller::WS::js;

use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js'; }

use utf8;
use Data::OptList;
use DBDefs;
use HTTP::Request;
use Digest::MD5 qw( md5_hex );
use IO::Compress::Gzip qw( gzip $GzipError );
use JSON qw( encode_json decode_json );
use List::AllUtils qw( part uniq_by );
use MusicBrainz::Errors qw(
    build_request_and_user_context
    capture_exceptions
    send_message_to_sentry
);
use MusicBrainz::Server::WebService::Validator;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use MusicBrainz::Server::Filters;
use MusicBrainz::Server::Data::Search qw( escape_query );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Constants qw( entities_with %ENTITIES $CONTACT_URL );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw(
    is_database_row_id
    is_guid
    is_positive_integer
);
use Readonly;
use Scalar::Util qw( blessed );
use Text::Trim;
use Time::Piece;
use URI;
use XML::XPath;

# This defines what options are acceptable for WS calls
my $ws_defs = Data::OptList::mkopt([
    'medium' => {
        method => 'GET',
        inc => [ qw(recordings rels) ],
        optional => [ qw(q artist tracks limit page timestamp) ]
    },
    'tracks' => {
        method => 'GET',
        optional => [ qw(q page ) ]
    },
    'cdstub' => {
        method => 'GET',
        optional => [ qw(q artist tracks limit page timestamp) ]
    },
    'cover-art-upload' => {
        method => 'GET',
    },
    'entity' => {
        method => 'GET',
        inc => [ qw(rels) ]
    },
    'entities' => {
        method => 'GET',
    },
    'events' => {
        method => 'GET'
    },
    'type-info' => {
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

sub tracks : Chained('root') PathPart Args(1) {
    my ($self, $c, $medium_id) = @_;

    $self->detach_with_error($c, "malformed medium id: $medium_id", 400)
        unless is_database_row_id($medium_id);

    my $page = $c->stash->{args}{page} || 1;
    $self->detach_with_error($c, "malformed page: $page", 400)
        unless is_positive_integer($page);

    my ($pager, $tracks) = $c->model('Track')->load_for_medium_paged($medium_id, $page);
    $c->model('Track')->load_related_info($c->user_exists ? $c->user->id : undef, @$tracks);

    my $tracks_json_array = to_json_array($tracks);
    my $linked_entities = $MusicBrainz::Server::Entity::Util::JSON::linked_entities;

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body(encode_json({
        linked_entities => {
            link_attribute_type => ($linked_entities->{link_attribute_type} // {}),
            link_type => ($linked_entities->{link_type} // {}),
        },
        pager => serialize_pager($pager),
        tracks => $tracks_json_array,
    }));
}

sub cdstub : Chained('root') PathPart Args(1) {
    my ($self, $c, $id) = @_;

    my $cdstub = $c->model('CDStub')->get_by_discid($id);
    my $ret = {
        toc => '',
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

    $query = join(' AND ', @query);

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

sub _detach_with_ia_server_error {
    my ($self, $c, $error) = @_;

    $self->detach_with_error($c, {
        message => l(
            'An error occurred trying to communicate with the ' .
            'Internet Archive servers. Please wait a few moments ' .
            'and try again.',
        ),
        error_details => "$error",
    });
}

sub _detach_with_temporary_delay : Private {
    my ($self, $c) = @_;

    $self->detach_with_error($c, {
        message => l(
            'We’ve hit a temporary delay while trying to fetch metadata ' .
            'from the Internet Archive. Please wait a minute and try again.',
        ),
    }, 500);
}

sub cover_art_upload : Chained('root') PathPart('cover-art-upload') Args(1)
{
    my ($self, $c, $gid) = @_;

    $self->check_login($c, 'not logged in');

    my $mime_type = $c->request->params->{mime_type};
    unless ($c->model('CoverArtArchive')->is_valid_mime_type($mime_type)) {
        $self->detach_with_error($c, 'invalid mime_type');
    }

    my $bucket = 'mbid-' . $gid;

    # It's not currently possible for the IA to reserve the mbid-*
    # identifer space for the CAA account, so we're creating the bucket
    # before any edits can be submitted to ensure that we're the
    # owner. If it already exists, we ensure that we're the owner of
    # the existing bucket. Anomalies here should produce an error
    # informing the user to contact us; in that case we'll have to
    # contact the IA to transfer ownership and deal with any malicious
    # activity.

    my $context = $c->model('MB')->context;

    unless ($c->model('CoverArtArchive')->exists_for_release_gid($gid)) {
        my $bucket_uri = URI->new(DBDefs->COVER_ART_ARCHIVE_UPLOAD_PREFIXER($bucket));
        $bucket_uri->scheme('https');

        if (
            (DBDefs->DEVELOPMENT_SERVER || DBDefs->DB_STAGING_TESTING_FEATURES) &&
            $bucket_uri->authority !~ m/\.archive\.org$/
        ) {
            # This allows using contrib/ssssss.psgi for testing, but
            # we have two checks to make sure we're not leaking
            # credentials over HTTP in production.
            $bucket_uri->scheme('http');
        }

        my $s3_request = HTTP::Request->new(PUT => $bucket_uri->as_string);
        $s3_request->header(
            'authorization' => sprintf(
                'LOW %s:%s',
                DBDefs->COVER_ART_ARCHIVE_ACCESS_KEY,
                DBDefs->COVER_ART_ARCHIVE_SECRET_KEY,
            ),
        );
        $s3_request->header('x-archive-meta-collection' => 'coverartarchive');
        $s3_request->header('x-archive-auto-make-bucket' => '1');
        $s3_request->header('x-archive-meta-mediatype' => 'image');
        $s3_request->header('x-archive-meta-noindex' => 'true');

        $context->lwp->timeout(30);

        my $response = $context->lwp->request($s3_request);
        if ($response->is_success) {
            # The bucket was created succesfully.
        } elsif ($response->code == 409) {
            my $s3_error_code;
            my $xp_error;

            capture_exceptions(sub {
                my $xp = XML::XPath->new(xml => $response->decoded_content);
                $s3_error_code = $xp->find('/Error/Code')->string_value;
            }, sub {
                $xp_error = shift;
            });

            if (!defined $s3_error_code || defined $xp_error) {
                $self->_detach_with_ia_server_error($c, $xp_error);
            }

            if ($s3_error_code eq 'BucketAlreadyExists') {
                # Check that we're the owner of the existing bucket.
                my $ia_metadata_uri = DBDefs->COVER_ART_ARCHIVE_IA_METADATA_PREFIX . "/$bucket";
                $response = $context->lwp->request(HTTP::Request->new(GET => $ia_metadata_uri));

                my $item_metadata_content = $response->decoded_content;
                my $item_metadata;
                my $json_decode_error;

                if ($response->is_success) {
                    capture_exceptions(sub {
                        $item_metadata = $c->json->decode($item_metadata_content);
                    }, sub {
                        $json_decode_error = shift;
                    });
                } else {
                    $self->_detach_with_ia_server_error($c, $item_metadata_content);
                }

                if (
                    !defined $item_metadata ||
                    ref($item_metadata) ne 'HASH' ||
                    defined $json_decode_error
                ) {
                    $self->_detach_with_ia_server_error($c, $json_decode_error);
                }

                unless (%{$item_metadata}) {
                    # If the response is an empty object, we're waiting for
                    # the item to become registered in the metadata service.
                    $self->_detach_with_temporary_delay($c);
                }

                if ($item_metadata->{is_dark}) {
                    $self->detach_with_error(
                        $c,
                        {
                            # Uses the same string as in root/release/CoverArtDarkened.js
                            message => l(
                                'The Cover Art Archive has had a takedown ' .
                                'request in the past for this release, so we ' .
                                'are unable to allow any more uploads.',
                            ),
                        },
                    );
                }

                my $uploader = $item_metadata->{metadata}{uploader};
                if (!defined $uploader) {
                    send_message_to_sentry(
                        "Undefined uploader for CAA item at $ia_metadata_uri",
                        build_request_and_user_context($c),
                        extra => {
                            response_code => $response->code,
                            response_content => $item_metadata_content,
                        },
                    );
                    $self->_detach_with_ia_server_error(
                        $c,
                        'uploader is undef',
                    );
                }

                if ($uploader ne 'caa@musicbrainz.org') {
                    send_message_to_sentry(
                        "Bad uploader for CAA item at $ia_metadata_uri",
                        build_request_and_user_context($c),
                        extra => {
                            response_code => $response->code,
                            response_content => $item_metadata_content,
                        },
                    );
                    $self->detach_with_error(
                        $c,
                        {
                            message => l(
                                'Cover art can’t be uploaded to this release ' .
                                'because we don’t own the associated item at ' .
                                'the Internet Archive. Please contact us at ' .
                                '{contact_url} so we can resolve this.',
                                {contact_url => $CONTACT_URL},
                            ),
                        },
                    );
                }
            }
        } else {
            send_message_to_sentry(
                'Error creating CAA item bucket at ' . $bucket_uri->as_string,
                build_request_and_user_context($c),
                extra => {
                    response_code => $response->code,
                    response_content => $response->decoded_content,
                },
            );
            $self->_detach_with_ia_server_error($c, $response->decoded_content);
        }
    }

    my $id = $c->request->params->{image_id} // $c->model('CoverArtArchive')->fresh_id;

    if ($c->model('CoverArtArchive')->is_id_in_use($id)) {
        $self->detach_with_error($c, {message => "The ID $id is already in use (1)."});
    }

    # Create a nonce associated with this image ID which we'll later
    # use to verify that the user went through this endpoint to
    # initiate the upload. This is necessary to ensure we're the owner
    # of the bucket (see above) before allowing any edit submission.
    my $nonce_key = 'cover_art_upload_nonce:' . $id;
    my $existing_nonce = $context->store->get($nonce_key);
    if ($existing_nonce) {
        $self->detach_with_error($c, {message => "The ID $id is already in use (2)."});
    }
    my $nonce = $c->generate_nonce;
    $context->store->set($nonce_key, $nonce);
    # Expire the nonce in 1 hour.
    $context->store->expire($nonce_key, 60 * 60);

    my %s3_policy;
    $s3_policy{mime_type} = $mime_type;
    $s3_policy{redirect} = $c->uri_for_action('/release/cover_art_uploaded', [ $gid ])->as_string()
        if $c->request->params->{redirect};

    my $expiration = gmtime() + 3600;
    $s3_policy{expiration} = $expiration->datetime . '.000Z';

    my $data = {
        action => DBDefs->COVER_ART_ARCHIVE_UPLOAD_PREFIXER($bucket),
        image_id => "$id",
        formdata => $c->model('CoverArtArchive')->post_fields($bucket, $gid, $id, \%s3_policy),
        nonce => $nonce,
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
        $c->stash->{error} = 'The requested entity was not found.';
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

Readonly our $MAX_FETCHED_ENTITIES => 25;

Readonly our $MAX_FETCHED_ENTITIES_URL_LENGTH => (
    # 36 => Length of an MBID.
    # 24 => Number of separators.
    ($MAX_FETCHED_ENTITIES * 36) + ($MAX_FETCHED_ENTITIES - 1)
);

sub entities : Chained('root') PathPart('entities') Args(2)
{
    my ($self, $c, $type_name, $raw_ids) = @_;

    my $type_model_name = eval { type_to_model($type_name) };

    $self->detach_with_error($c, "unknown type: $type_name", 400)
        if $@;

    my $type_model = $c->model($type_model_name);

    # Limit to 25 MBIDs.
    my @input_values =
        split /\+/,
        (substr $raw_ids, 0, $MAX_FETCHED_ENTITIES_URL_LENGTH);

    if (scalar(@input_values) > $MAX_FETCHED_ENTITIES) {
        @input_values = @input_values[0 .. ($MAX_FETCHED_ENTITIES - 1)];
    }

    my ($ids, $gids, $invalid_ids) = part {
        is_database_row_id($_) ? 0 : (is_guid($_) ? 1 : 2)
    } @input_values;

    if (defined $invalid_ids && @$invalid_ids) {
        $self->detach_with_error(
            $c,
            'invalid ids: ' . (join q(, ), @$invalid_ids),
            400,
        );
    }

    my @ids = defined $ids ? @$ids : ();
    my @gids = defined $gids ? @$gids : ();

    if (@ids && !$type_model->can('get_by_ids')) {
        $self->detach_with_error($c, "model does not support numeric ids: $type_name", 400)
    }

    if (@gids && !$type_model->can('get_by_gids')) {
        $self->detach_with_error($c, "model does not support gids: $type_name", 400)
    }

    my $results = {};
    my $serializer = $c->stash->{serializer};

    if (@ids) {
        my $id_obj_map = $type_model->get_by_ids(@ids);
        for my $id (@ids) {
            my $entity = $id_obj_map->{$id};
            if (defined $entity) {
                $results->{$id} = $entity;
            }
        }
    }

    if (@gids) {
        my $gid_obj_map = $type_model->get_by_gids(@gids);
        for my $gid (@gids) {
            my $entity = $gid_obj_map->{$gid};
            if (defined $entity) {
                $results->{$gid} = $entity;
            }
        }
    }

    if ($ENTITIES{$type_name}{artist_credits}) {
        $c->model('ArtistCredit')->load(values %{$results});
    }

    while (my ($id, $entity) = each %{$results}) {
        $results->{$id} = $entity->TO_JSON;
    }

    $c->res->content_type($serializer->mime_type . '; charset=utf-8');
    $c->res->body(encode_json({
        results => $results,
    }));
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

sub type_info : Chained('root') PathPart('type-info') Args(1) {
    my ($self, $c, $type_name) = @_;

    my $type_model_name = eval { type_to_model($type_name) };

    $self->detach_with_error($c, "unknown type: $type_name", 400)
        if $@;

    my $type_model = $c->model($type_model_name);

    $self->detach_with_error($c, "unsupported type: $type_name", 400)
        unless $type_model->can('get_all');

    my $cache = $c->model('MB')->cache;
    my $cache_key = "js_${type_name}_info";
    my $response = $cache->get($cache_key);
    my $etag = $cache->get("$cache_key:etag");

    unless (defined $response) {
        my @all_types = $type_model->get_all;
        if ($type_name eq 'language') {
            @all_types = grep { $_->frequency != 0 } @all_types;
        } elsif ($type_name eq 'script') {
            @all_types = grep { $_->frequency != 1 } @all_types;
        }
        my $response_obj = {
            "${type_name}_list" => \@all_types,
        };
        my $encoded_json = $c->json_canonical_utf8->encode($response_obj);
        gzip(\$encoded_json => \$response) or die qq(gzip failed: $GzipError);
        $cache->set($cache_key, $response);
        $etag = undef;
    }

    unless (defined $etag) {
        $etag = md5_hex($response);
        $cache->set("$cache_key:etag", $etag);
    }

    $c->res->content_type('application/json; charset=utf-8');
    $c->res->content_encoding('gzip');
    $c->response->headers->etag($etag);
    $c->res->body($response);
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
