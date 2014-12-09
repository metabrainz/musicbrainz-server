#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( %ENTITIES entities_with );
use MusicBrainz::Server::Data::Relationship;
use DBDefs;
use Sql;
use Getopt::Long;
use URI::Escape qw( uri_escape_utf8 );
use Try::Tiny;

use WWW::SitemapIndex::XML;
use WWW::Sitemap::XML;
use DateTime;
use List::Util qw( min );
use List::UtilsBy qw( sort_by );
use File::Slurp qw( read_dir );
use Digest::MD5 qw( md5_hex );
use Readonly;

# Constants
Readonly my $EMPTY_PAGE_PRIORITY => 0.1;
Readonly my $SECONDARY_PAGE_PRIORITY => 0.3;

# Check options

my $web_server = DBDefs->CANONICAL_SERVER;
my $fHelp;
my $fCompress = 1;
my $fPing = 0;

GetOptions(
    "help"                        => \$fHelp,
    "compress|c!"                 => \$fCompress,
    "ping|p"                      => \$fPing,
    "web-server=s"                => \$web_server,
) or exit 2;

=head1 SYNOPSIS

admin/BuildSitemaps.pl: build XML sitemaps/sitemap-indexes to a standard location.

Options:

    --help             show this help
    --compress/-c      compress (default true)
    --ping/-p          ping search engines once built
    --web-server       provide a web server as the base to use in sitemap-index
                       files (without trailing slash).
                       Defaults to DBDefs->CANONICAL_SERVER
=cut

sub usage {
    print <<EOF;
Usage: BuildSitemaps.pl [options]

    --help             show this help
    --compress/-c      compress (default true)
    --ping/-p          ping search engines once built
    --web-server       provide a web server as the base to use in sitemap-index
                       files (without trailing slash).
                       Defaults to DBDefs->CANONICAL_SERVER
EOF
}

usage(), exit if $fHelp;

=head1 DESCRIPTION

=over

=item 1.

First, creates a context C<$c> to use, especially its Sql object (C<$sql>).

=cut

my $c = MusicBrainz::Server::Context->create_script_context;
my $sql = Sql->new($c->conn);

print localtime() . " Building sitemaps and sitemap index files\n";

=pod

=item 2.

Set up a sitemap index object C<$index>.

=cut

my $index_filename = "sitemap-index.xml";
$index_filename .= '.gz' if $fCompress;
my $index_localname = "$FindBin::Bin/../root/static/sitemaps/$index_filename";

my $index = WWW::SitemapIndex::XML->new();

=pod

=item 3.

Create a (global) variable C<@sitemap_files> to store the list of sitemap files in;
this is used to determine which files to delete during cleanup

=cut
my @sitemap_files;

=pod

=item 4.

Load old index (if present) to keep track of the modification times of
sitemaps, in case they're unchanged.

=cut

my %old_sitemap_modtime;
if (-f $index_localname) {
    my $old_index = WWW::SitemapIndex::XML->new();
    $old_index->load( location => $index_localname );
    %old_sitemap_modtime = map { $_->loc => $_->lastmod } grep { $_->loc && $_->lastmod } $old_index->sitemaps;
}

=pod

=item 5.

Build sitemaps by looping over each entity type that's applicable and calling
C<build_one_entity>. Runs in one transaction for data consistency.

=cut

$sql->begin;
for my $entity_type (entities_with(['mbid', 'indexable']), 'cdtoc') {
    build_one_entity($entity_type, $index, $sql);
}
$sql->commit;

=pod

=item 6.

Once all sitemaps are built, use C<$index> to write a sitemap index file.

=cut

$index->write($index_localname);
push @sitemap_files, $index_filename;

# This needs adding or it'll get deleted every time
push @sitemap_files, '.gitkeep';

=pod

=item 7.

Then, remove any file that wasn't just built, to remove outdated files.

=cut

print localtime() . " Built index $index_filename, deleting outdated files\n";
my @files = read_dir("$FindBin::Bin/../root/static/sitemaps");
for my $file (@files) {
    if (!grep { $_ eq $file } @sitemap_files) {
        print localtime() . " removing $file\n";
        unlink "$FindBin::Bin/../root/static/sitemaps/$file";
    }
}

=pod

=item 8.

Finally, ping search engines (if the option is turned on) and finish.

=back

=cut

# Ping search engines, if applicable
if ($fPing) {
    print localtime() . " Pinging search engines\n";
    ping_search_engines($c, "$web_server/$index_filename");
}

print localtime() . " Done\n";

# --------------- END MAIN BODY ---------------

=head1 FUNCTIONS

=head2 build_one_entity

The "main loop" function. Takes an entity type, figures out batches to build
and what to build for each batch, then calls out to do it.

=cut

sub build_one_entity {
    my ($entity_type, $index, $sql) = @_;

    # Find the counts in each potential batch of 50,000
    my $raw_batches = $sql->select_list_of_hashes(
        "SELECT batch, count(id) from (SELECT id, ceil(id / 50000.0) AS batch FROM $entity_type) q GROUP BY batch ORDER BY batch ASC"
    );
    my @batches;

    # Exclude the last batch, which should always be its own sitemap.
    if (scalar @$raw_batches > 1) {
        my $batch = {count => 0, batches => []};
        for my $raw_batch (@{ $raw_batches }[0..scalar @$raw_batches-2]) {
            # Add this potential batch to the previous one if the sum will come out less than 50,000
            # Otherwise create a new batch and push the previous one onto the list.
            if ($batch->{count} + $raw_batch->{count} <= 50000) {
                $batch->{count} = $batch->{count} + $raw_batch->{count};
                push @{$batch->{batches}}, $raw_batch->{batch};
            } else {
                push @batches, $batch;
                $batch = {count => $raw_batch->{count}, batches => [$raw_batch->{batch}]};
            }
        }
        push @batches, $batch;
    }

    # Add last batch.
    my $last_batch = $raw_batches->[scalar @$raw_batches - 1];
    push @batches, {count =>   $last_batch->{count},
                    batches => [$last_batch->{batch}]};

    my $suffix_info = build_suffix_info($entity_type);

    for my $batch_info (@batches) {
        build_one_batch($entity_type, $batch_info, $suffix_info, $index, $sql);
    }
}

=head2 build_suffix_info

Given an entity type, build information about URL suffixes and their associated
SQL and priorities.

=cut

sub build_suffix_info {
    my ($entity_type) = @_;
    my $entity_properties = $ENTITIES{$entity_type} // {};
    my $suffix_info = {};
    if ($entity_properties->{aliases}) {
        $suffix_info->{aliases} = {
            suffix => 'aliases',
            priority => sub {
                my (%opts) = @_;
                return $SECONDARY_PAGE_PRIORITY if $opts{has_aliases};
                return $EMPTY_PAGE_PRIORITY;
            },
            extra_sql => {columns => "EXISTS (SELECT true FROM ${entity_type}_alias a WHERE a.$entity_type = ${entity_type}.id) AS has_aliases"}
        };
    }
    if ($entity_type eq 'release') {
        $suffix_info->{'cover-art'} = {
            suffix => 'cover-art',
            priority => sub {
                my (%opts) = @_;
                return $SECONDARY_PAGE_PRIORITY if $opts{cover_art_presence} eq 'present';
                return $EMPTY_PAGE_PRIORITY;
            },
            extra_sql => {join => 'release_meta ON release.id = release_meta.id',
                          columns => 'cover_art_presence'}
        };
    }
    if ($entity_properties->{mbid}{relatable} eq 'dedicated') {
        my @tables = MusicBrainz::Server::Data::Relationship::_generate_table_list($entity_type, grep { $_ ne 'url' } entities_with(['mbid','relatable']));
        my $select = join(' UNION ALL ', map { 'SELECT TRUE FROM ' . $_->[0] . ' WHERE ' . $_->[1] . " = ${entity_type}.id" } @tables);
        $suffix_info->{relationships} = {
            suffix => 'relationships',
            priority => sub {
                my (%opts) = @_;
                return $SECONDARY_PAGE_PRIORITY if $opts{has_non_url_rels};
                return $EMPTY_PAGE_PRIORITY;
            },
            extra_sql => {columns => "EXISTS ($select) AS has_non_url_rels"}
        };
    }
    return $suffix_info;
}

=head2 build_one_batch

Called by C<build_one_entity> for a given batch. Fetches the set of base URLs
and then builds the main sitemaps and any suffix sitemaps.

=cut

sub build_one_batch {
    my ($entity_type, $batch_info, $suffix_info, $index, $sql) = @_;

    my $minimum_batch_number = min(@{ $batch_info->{batches} });
    my $entity_id = $entity_type eq 'cdtoc' ? 'discid' : 'gid';

    # Merge the extra joins/columns needed for particular suffixes
    my %extra_sql = (join => '', columns => []);
    for my $suffix (keys %$suffix_info) {
        my %extra = %{$suffix_info->{$suffix}{extra_sql} // {}};
        if ($extra{columns}) {
            push(@{ $extra_sql{columns} }, $extra{columns});
        }
        if ($extra{join}) {
            $extra_sql{join} .= " JOIN $extra{join}";
        }
    }
    my $columns = join(', ', "$entity_id AS main_id", @{ $extra_sql{columns} });
    my $tables = $entity_type . $extra_sql{join};

    my $query = "SELECT $columns FROM $tables " .
                "WHERE ceil(${entity_type}.id / 50000.0) = any(?) " .
                "ORDER BY ${entity_type}.id ASC";
    my $ids = $sql->select_list_of_hashes($query, $batch_info->{batches});

    build_one_sitemap($entity_type, $minimum_batch_number, $index, $ids);
    for my $suffix (keys %$suffix_info) {
        my %opts = %{ $suffix_info->{$suffix} // {}};
        build_one_sitemap($entity_type, $minimum_batch_number, $index, $ids, %opts);
    }
}

=head2 build_one_sitemap

Called by C<build_one_batch> to build an individual sitemap given the necessary
information to build the sitemap.

=cut

sub build_one_sitemap {
    my ($entity_type, $minimum_batch_number, $index, $ids, %opts) = @_;
    my $entity_properties = $ENTITIES{$entity_type} // {};
    my $filename = "sitemap-$entity_type-$minimum_batch_number";
    if ($opts{suffix}) {
        $filename .= "-$opts{suffix}";
    }
    $filename .= $fCompress ? '.xml.gz' : '.xml';

    local $| = 1; # autoflush stdout
    print localtime() . " Building $filename...";

    my $local_filename = "$FindBin::Bin/../root/static/sitemaps/$filename";
    my $remote_filename = $web_server . '/' . $filename;
    my $existing_md5;

    if (-f $local_filename) {
        $existing_md5 = hash_sitemap($local_filename);
    }

    my $entity_url = $entity_properties->{url} || $entity_type;

    my $map = WWW::Sitemap::XML->new();
    for my $id_info (@$ids) {
        my $id = $id_info->{main_id};
        my $url = $web_server . '/' . $entity_url . '/' . $id;
        if ($opts{suffix}) {
            $url .= "/$opts{suffix}";
        }
        # Default priority is 0.5, per spec.
        my %add_opts = (loc => $url);
        if ($opts{priority}) {
            $add_opts{priority} = ref $opts{priority} eq 'CODE' ? $opts{priority}->(%$id_info) : $opts{priority};
        }
        $map->add(%add_opts);
    }
    $map->write($local_filename);
    push @sitemap_files, $filename;

    my $modtime = DateTime->now->date(); # YYYY-MM-DD
    if ($existing_md5 && $existing_md5 eq hash_sitemap($map) && $old_sitemap_modtime{$remote_filename}) {
        print "using previous modtime, since file unchanged...";
        $modtime = $old_sitemap_modtime{$remote_filename};
    }

    $index->add(loc => $remote_filename, lastmod => $modtime);
    print " built.\n";
}

=head2 ping_search_engines

Use the context's LWP to ping each appropriate search engine URL, given the
remove URL of the sitemap index.

=cut

sub ping_search_engines {
    my ($c, $url) = @_;

    my @sitemap_prefixes = ('http://www.google.com/webmasters/tools/ping?sitemap=', 'http://www.bing.com/webmaster/ping.aspx?siteMap=');
    for my $prefix (@sitemap_prefixes) {
        try {
            my $ping_url = $prefix . uri_escape_utf8($url);
            $c->lwp->get($ping_url);
        } catch {
            print "Failed to ping $prefix.\n";
        }
    }
}

=head2 hash_sitemap

Used by C<build_one_sitemap> to determine if a sitemap has changed since the
previous build, for insertion to the sitemap index, by sorting consistenly,
joining together applicable properties, and md5ing the URL contents of a
sitemap. It's passed either a filename or an already-initialized C<$map>
object.

=cut

sub hash_sitemap {
    my ($filename_or_map) = @_;
    my $map;
    if (ref($filename_or_map) eq '') {
        $map = WWW::Sitemap::XML->new();
        $map->load( location => $filename_or_map );
    } else {
        $map = $filename_or_map;
    }
    return md5_hex(join('|', map { join(',', $_->loc, $_->lastmod // '', $_->changefreq // '', $_->priority // '') } sort_by { $_->loc } $map->urls));
}

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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
