package MusicBrainz::Server::Data::Role::ArtArchive;
use Moose::Role;

with 'MusicBrainz::Server::Data::Role::Sql';
use DBDefs;
use Digest::HMAC_SHA1;
use JSON;
use MIME::Base64 qw( encode_base64 );
use Time::HiRes qw( time );
use MusicBrainz::Server::Data::Utils qw( type_to_model );

# Name of the archive (e.g. cover, event).
requires 'art_archive_name';
# Type of entity associated with the artwork (e.g. release, event).
requires 'art_archive_entity';
# Attributes in the index_listing view that indicate artwork type
# (e.g. is_front, is_back).
requires 'art_archive_type_booleans';
requires 'art_model_name';
requires 'download_prefix';

sub art_table {
    my $archive = shift->art_archive_name;
    return "${archive}_art_archive.${archive}_art";
}

sub art_model {
    my ($self) = @_;
    $self->c->model($self->art_model_name);
}

sub art_type_model_name { shift->art_model_name . 'Type' }

sub art_type_model {
    my ($self) = @_;
    $self->c->model($self->art_type_model_name);
}

has entity_model_name => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    builder => '_build_entity_model_name',
);

sub _build_entity_model_name {
    my ($self) = @_;
    type_to_model($self->art_archive_entity);
}

has entity_model => (
    is => 'ro',
    lazy => 1,
    builder => '_build_entity_model',
);

sub _build_entity_model {
    my ($self) = @_;
    $self->c->model($self->entity_model_name);
}

sub get_stats_for_entities {
    my ($self, @entity_ids) = @_;

    my $archive = $self->art_archive_name;
    my $entity_type = $self->art_archive_entity;

    my $type_columns = join q(, ), map {
        "bool_or($_) " . ($_ =~ s/^is_//r)
    } $self->art_archive_type_booleans;

    my $stats = $self->sql->select_list_of_hashes(<<~"SQL", \@entity_ids);
        SELECT $entity_type, count(*) total, $type_columns
          FROM ${archive}_art_archive.index_listing
         WHERE $entity_type = any(?)
         GROUP BY $entity_type
        SQL

    return {
        map {
            my $entity = delete $_->{$entity_type};
            ($entity => $_)
        } @$stats,
    };
}

sub is_valid_mime_type {
    my ($self, $mime_type) = @_;

    # N.B. event_art_archive.event_art.mime_type is simply an FK to
    # cover_art_archive.image_type.mime_type.

    $self->sql->select_single_value(
        'SELECT 1 FROM cover_art_archive.image_type WHERE mime_type = ?',
        $mime_type,
    );
}

sub mime_types {
    my $self = shift;

    return $self->sql->select_list_of_hashes(<<~'SQL');
        SELECT mime_type, suffix FROM cover_art_archive.image_type
        SQL
}

sub image_type_suffix {
    my ($self, $mime_type) = @_;

    return $self->sql->select_single_value(<<~'SQL', $mime_type);
        SELECT suffix FROM cover_art_archive.image_type WHERE mime_type = ?
        SQL
}

sub is_id_in_use {
    my ($self, $id) = @_;

    my $art_table = $self->art_table;

    $self->sql->select_single_value(
        "SELECT 1 FROM $art_table WHERE id = ?",
        $id,
    );
}

sub fresh_id {
    return int((time() - 1327528905) * 100);
}

=method post_fields

Generate the policy and form values to upload cover art.

=cut

sub post_fields {
    my ($self, $bucket, $mbid, $id, $opts) = @_;

    my $mime_type = $opts->{mime_type} // 'image/jpeg';
    my $redirect = $opts->{redirect};
    my $suffix = $self->image_type_suffix($mime_type);

    # We have one access key for both the coverartarchive and eventartarchive.
    my $access_key = $opts->{access_key} // DBDefs->INTERNET_ARCHIVE_ACCESS_KEY;
    my $secret_key = $opts->{secret_key} // DBDefs->INTERNET_ARCHIVE_SECRET_KEY;
    my $filename = "mbid-$mbid-$id.$suffix";

    my $archive = $self->art_archive_name;

    my %extra_fields = (
        'x-archive-auto-make-bucket' => '1',
        'x-archive-meta-collection' => "${archive}artarchive",
        'x-archive-meta-mediatype' => 'image',
        'x-archive-meta-noindex' => 'true',
    );

    my $policy = {
        expiration => $opts->{expiration},
        conditions => [
            {bucket => $bucket},
            {acl => 'public-read'},
            ($redirect ? {success_action_redirect => $redirect} : ()),
            ['eq', '$key', $filename],
            ['starts-with', '$content-type', $mime_type],
            (map { ['eq', "\$$_", $extra_fields{$_}] } sort keys %extra_fields),
        ],
    };

    my $policy_base64 = encode_base64(JSON->new->canonical->utf8->encode($policy), '');
    my $policy_signature_base64 = encode_base64(Digest::HMAC_SHA1::hmac_sha1($policy_base64, $secret_key), '');

    my $ret = {
        AWSAccessKeyId => $access_key,
        policy => $policy_base64,
        signature => $policy_signature_base64,
        key => $filename,
        acl => 'public-read',
        'content-type' => $mime_type,
        %extra_fields,
    };

    $ret->{success_action_redirect} = $redirect if $redirect;

    return $ret;
}

sub insert_art {
    my ($self, $entity_id, $edit, $art_id, $position, $types, $comment,
        $mime_type) = @_;

    my $entity_type = $self->art_archive_entity;
    my $art_table = $self->art_table;
    my $art_type_table = "${art_table}_type";

    # make sure the position slot is available.
    $self->sql->do(<<~"SQL", $entity_id, $position);
        UPDATE $art_table
           SET ordering = ordering + 1
         WHERE $entity_type = ?
           AND ordering >= ?
        SQL

    $self->sql->do(
        "INSERT INTO $art_table " .
            "($entity_type, mime_type, edit, ordering, id, comment) " .
        'VALUES (?, ?, ?, ?, ?, ?)',
        $entity_id, $mime_type, $edit, $position, $art_id, $comment,
    );

    for my $type_id (@$types) {
        $self->sql->do(
            "INSERT INTO $art_type_table (id, type_id) VALUES (?, ?)",
            $art_id, $type_id,
        );
    }
}

sub update_art {
    my ($self, $entity_id, $art_id, $types, $comment) = @_;

    my $art_table = $self->art_table;
    my $art_type_table = "${art_table}_type";

    if (defined $comment) {
        $self->sql->do(
            "UPDATE $art_table SET comment = ? WHERE id = ?",
            $comment, $art_id,
        );
    }

    if (defined $types) {
        $self->sql->do(
            "DELETE FROM $art_type_table WHERE id = ?",
            $art_id,
        );

        for my $type_id (@$types) {
            $self->sql->do(
                "INSERT INTO $art_type_table (id, type_id) VALUES (?, ?)",
                $art_id, $type_id,
            );
        }
    }
}

sub reorder_art {
    my ($self, $entity_id, $positions) = @_;

    my $art_table = $self->art_table;

    my $values = join ', ',
        (('(?::bigint, ?::integer)') x (keys %$positions));

    $self->sql->do(<<~"SQL", %$positions);
        UPDATE $art_table
           SET ordering = position.ordering
          FROM (VALUES $values) AS position (id, ordering)
         WHERE $art_table.id = position.id
        SQL
}

sub delete {
    my ($self, $id) = @_;

    my $art_table = $self->art_table;

    $self->sql->do("DELETE FROM $art_table WHERE id = ?", $id);
}

sub merge_entities {
    my ($self, $new_entity, @old_entities) = @_;

    my $archive = $self->art_archive_name;
    my $entity_type = $self->art_archive_entity;
    my $meta_table = "${entity_type}_meta";
    my $art_table = $self->art_table;

    # *_art_presence enum has 'darkened' as max, and 'absent' as min,
    # so we always want the highest value to be preserved
    my $presence = "${archive}_art_presence";
    $self->sql->do(<<~"SQL", [$new_entity, @old_entities], $new_entity);
        UPDATE $meta_table SET $presence = (
            SELECT max($presence)
              FROM $meta_table
             WHERE id = any(?)
        ) WHERE id = ?
        SQL

    for my $old_entity (@old_entities) {
        $self->sql->do(<<~"SQL", $new_entity, $old_entity);
            UPDATE $art_table
               SET $entity_type = \$1,
                   ordering = ordering + coalesce((
                        SELECT max(ordering)
                          FROM $art_table
                         WHERE $entity_type = \$1
                   ), 0)
             WHERE $entity_type = \$2
            SQL
    }
}

sub exists {
    my ($self, $id) = @_;

    my $art_table = $self->art_table;

    $self->c->sql->select_single_value(
        "SELECT TRUE FROM $art_table WHERE id = ?",
        $id,
    );
}

sub exists_for_entity_gid {
    my ($self, $entity_gid) = @_;

    my $art_table = $self->art_table;
    my $entity_type = $self->art_archive_entity;

    $self->c->sql->select_single_value(<<~"SQL", $entity_gid);
        SELECT 1 FROM $art_table a
          JOIN $entity_type e ON e.id = a.$entity_type
         WHERE e.gid = ?
        SQL
}

no Moose::Role;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011, 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
