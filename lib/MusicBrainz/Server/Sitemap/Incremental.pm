package MusicBrainz::Server::Sitemap::Incremental;

use strict;
use warnings;

use feature 'state';

use Digest::SHA qw( sha1_hex );
use File::Temp qw( tempdir );
use JSON qw( decode_json );
use List::UtilsBy qw( partition_by );
use Moose;
use Sql;

use MusicBrainz::Script::Utils qw( log );
use MusicBrainz::Server::Constants qw( entities_with );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Sitemap::Constants qw( %SITEMAP_SUFFIX_INFO );
use MusicBrainz::Server::Sitemap::Builder;

extends 'MusicBrainz::Server::Sitemap::Builder';

with 'MooseX::Runnable';
with 'MusicBrainz::Script::Role::IncrementalDump';
with 'MusicBrainz::Script::Role::TestCacheNamespace';

my %INDEXABLE_ENTITIES = map { $_ => 1 } entities_with(['mbid', 'indexable']);
my @LASTMOD_ENTITIES = grep { exists $INDEXABLE_ENTITIES{$_} }
                       entities_with('sitemaps_lastmod_table');

sub make_jsonld_request {
    my ($c, $url) = @_;

    my %extra_headers;
    if ($ENV{MUSICBRAINZ_RUNNING_TESTS}) {
        $extra_headers{'mb-set-database'} = 'TEST_SITEMAPS';
    }
    $c->lwp->get($url, Accept => 'application/ld+json', %extra_headers);
}

sub dump_schema { 'sitemaps' }

sub dumped_entity_types { \@LASTMOD_ENTITIES }

sub handle_update_path($$$$) {
    my ($self, $c, $entity_type, $entity_rows, $fetch) = @_;

    my $suffix_info = $SITEMAP_SUFFIX_INFO{$entity_type};

    for my $suffix_key (sort keys %{$suffix_info}) {
        my $opts = $suffix_info->{$suffix_key};

        next unless $opts->{jsonld_markup};

        for my $row (@{$entity_rows}) {
            my $was_updated = $fetch->(
                $row,
                paginated => 0,
                sitemap_suffix_key => $suffix_key,
            );

            if ($opts->{paginated}) {
                my $page = 2;
                while ($was_updated) {
                    $was_updated = $fetch->(
                        $row,
                        paginated => 1,
                        sitemap_suffix_key => $suffix_key,
                        page_number => $page,
                    );
                    $page++;
                }
            }
        }
    }
}

sub get_changed_documents {
    my ($self, $c, $entity_type, $row, $update, %extra_args) = @_;

    state $attempts = {};
    state $canonical_json = JSON->new->canonical->utf8;

    my $row_id = $row->{id};
    my $web_server = DBDefs->WEB_SERVER;
    my $canonical_server = DBDefs->CANONICAL_SERVER;
    my $url = $self->build_page_url_from_row($entity_type, $row->{gid}, %extra_args);
    my $request_url = $url;
    $request_url =~ s{\Q$canonical_server\E}{http://$web_server};

    my $response = make_jsonld_request($c, $request_url);

    # Responses should never redirect. If they do, we likely requested a page
    # number that doesn't exist.
    if ($response->previous) {
        log("Got redirect fetching $request_url, skipping");
        return 0;
    }

    if ($response->is_success) {
        my $new_hash = sha1_hex($canonical_json->encode(decode_json($response->content)));
        my ($operation, $last_modified, $replication_sequence) =
            @{$update}{qw(operation last_modified replication_sequence)};

        return Sql::run_in_transaction(sub {
            # Fallback for where the source table had no `last_updated` or
            # `created` columns.
            unless (defined $last_modified) {
                $last_modified = $c->sql->select_single_value('SELECT now()');
            }

            my $old_hash = $c->sql->select_single_value(<<~"SQL", $row_id, $url);
                SELECT encode(jsonld_sha1, 'hex')
                FROM sitemaps.${entity_type}_lastmod
                WHERE id = ? AND url = ?
                SQL

            if (defined $old_hash) {
                if ($old_hash ne $new_hash) {
                    log("Found change at $url");

                    $c->sql->do(<<~"SQL", "\\x$new_hash", $last_modified, $replication_sequence, $row_id, $url);
                        UPDATE sitemaps.${entity_type}_lastmod
                        SET jsonld_sha1 = ?, last_modified = ?, replication_sequence = ?
                        WHERE id = ? AND url = ?
                        SQL
                    return 1;
                }
                log("No change at $url");
            } else {
                log("Inserting lastmod entry for $url");

                $c->sql->do(
                    qq{INSERT INTO sitemaps.${entity_type}_lastmod (
                        id,
                        url,
                        paginated,
                        sitemap_suffix_key,
                        jsonld_sha1,
                        last_modified,
                        replication_sequence
                    ) VALUES (?, ?, ?, ?, ?, ?, ?)},
                    $row_id,
                    $url,
                    $extra_args{paginated},
                    $extra_args{sitemap_suffix_key},
                    "\\x$new_hash",
                    $last_modified,
                    $replication_sequence
                );

                # Indicate a "change" if this is a new entity.
                return 1 if (
                    $operation eq 'i' &&
                    get_ident($update) eq "musicbrainz.$entity_type.id" &&
                    $update->{value} == $row_id
                );
            }

            return 0;
        }, $c->sql);
    }

    my $code = $response->code;
    if ($code =~ /^5/) {
        if (!(defined $attempts->{$url}) || $attempts->{$url} < 3) {
            sleep 10;
            $attempts->{$url}++;
            return $self->get_changed_documents(
                $c,
                $entity_type,
                $row,
                $update,
                %extra_args,
            );
        }
    }

    log("ERROR: Got response code $code fetching $request_url");
    return 0;
}

sub build_page_url_from_row {
    my ($self, $entity_type, $gid, %extra_args) = @_;

    my $suffix_key = $extra_args{sitemap_suffix_key};
    my $opts = $SITEMAP_SUFFIX_INFO{$entity_type}{$suffix_key};
    my $url = $self->build_page_url($entity_type, $gid, %{$opts});

    if ($extra_args{paginated}) {
        my $use_amp = $url =~ m/\?/;
        my $page = $extra_args{page_number};
        $url .= ($use_amp ? '&' : '?') . "page=$page";
    }

    return $url;
}

sub should_follow_table {
    my ($self, $table) = @_;

    return 0 if $table eq 'cover_art_archive.cover_art_type';
    return 0 if $table eq 'musicbrainz.cdtoc';
    return 0 if $table eq 'musicbrainz.language';
    return 0 if $table eq 'musicbrainz.medium_cdtoc';
    return 0 if $table eq 'musicbrainz.medium_index';

    return 0 if $table =~ qr'[._](tag_|tag$)';
    return 0 if $table =~ qw'_(meta|raw|gid_redirect)$';

    return 1;
}

sub post_replication_sequence {
    my ($self, $c) = @_;

    for my $entity_type (@{ $self->dumped_entity_types }) {
        # The sitemaps.control columns will be NULL on first run, in which case
        # we just select all updates for writing.
        my $all_updates = $c->sql->select_list_of_hashes(
            "SELECT lm.*
               FROM sitemaps.${entity_type}_lastmod lm
              WHERE lm.replication_sequence > COALESCE(
                (SELECT overall_sitemaps_replication_sequence FROM sitemaps.control), 0)"
        );

        my %updates_by_suffix_key = partition_by {
            $_->{sitemap_suffix_key}
        } @{$all_updates};

        for my $suffix_key (sort keys %updates_by_suffix_key) {
            my $updates = $updates_by_suffix_key{$suffix_key};

            my (@base_urls, @paginated_urls);
            my $urls = {base => \@base_urls, paginated => \@paginated_urls};
            my $suffix_info = $SITEMAP_SUFFIX_INFO{$entity_type}{$suffix_key};

            for my $update (@{$updates}) {
                my $opts = $self->create_url_opts(
                    $c,
                    $entity_type,
                    $update->{url},
                    $suffix_info,
                    {last_modified => $update->{last_modified}},
                );

                if ($update->{paginated}) {
                    push @paginated_urls, $opts;
                } else {
                    push @base_urls, $opts;
                }
            }

            my %opts = %{$suffix_info};
            my $filename_suffix = $opts{filename_suffix} // $opts{suffix};

            if ($filename_suffix) {
                $opts{filename_suffix} = "$filename_suffix-incremental";
            } else {
                $opts{filename_suffix} = 'incremental';
            }

            $self->build_one_suffix($entity_type, 1, $urls, %opts);
        }
    }
}

sub pre_key_traversal { }

around do_not_delete => sub {
    my ($orig, $self, $file) = @_;

    # Do not delete overall sitemap files.
    $self->$orig($file) || ($file !~ /incremental/);
};

sub run {
    my ($self) = @_;

    my $c = MusicBrainz::Server::Context->create_script_context(
        database => $self->database,
        fresh_connector => 1,
    );

    unless (-f $self->index_localname) {
        log('ERROR: No sitemap index file was found');
        exit 1;
    }

    if ($self->run_incremental_dump($c)) {
        $self->write_index;
        $self->ping_search_engines($c);
    }

    return 0;
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
