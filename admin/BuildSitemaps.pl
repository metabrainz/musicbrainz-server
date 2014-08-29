#!/usr/bin/env perl

use warnings;
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2014 MetaBrainz Foundation
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#____________________________________________________________________________

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( %ENTITIES entities_with );
use DBDefs;
use Sql;
use Getopt::Long;

use WWW::SitemapIndex::XML;
use WWW::Sitemap::XML;
use DateTime;
use List::Util qw( min );
use List::UtilsBy qw( sort_by );
use File::Slurp qw( read_dir );
use Digest::MD5 qw( md5_hex );

my $web_server = DBDefs->CANONICAL_SERVER;
my $fHelp;
my $fCompress = 1;

GetOptions(
    "help"                        => \$fHelp,
    "compress|c!"                 => \$fCompress,
    "web-server=s"                => \$web_server,
) or exit 2;

sub usage {
    print <<EOF;
Usage: BuildSitemaps.pl [options]

    --help             show this help
    --compress         compress (default true)
    --web-server       provide a web server as the base to use in sitemap-index
                       files (without trailing slash).
                       Defaults to DBDefs->CANONICAL_SERVER
EOF
}

usage(), exit if $fHelp;

my $c = MusicBrainz::Server::Context->create_script_context;
my $sql = Sql->new($c->conn);

print localtime() . " Building sitemaps and sitemap index files\n";

my $index_filename = "sitemap-index.xml";
$index_filename .= '.gz' if $fCompress;
my $index_localname = "$FindBin::Bin/../root/static/sitemaps/$index_filename";

my $index = WWW::SitemapIndex::XML->new();
my @sitemap_files;
my %old_sitemap_modtime;

if (-f $index_localname) {
    my $old_index = WWW::SitemapIndex::XML->new();
    $old_index->load( location => $index_localname );
    %old_sitemap_modtime = map { $_->loc => $_->lastmod } grep { $_->loc && $_->lastmod } $old_index->sitemaps;
}

$sql->begin;
for my $entity_type (entities_with(['mbid', 'indexable']), 'cdtoc') {
    build_one_entity($entity_type, $index, $sql);
}
$sql->commit;

$index->write($index_localname);
push @sitemap_files, $index_filename;

# This needs pushing or it'll get deleted every time
push @sitemap_files, '.gitkeep';

print localtime() . " Built index $index_filename, deleting outdated files\n";
my @files = read_dir("$FindBin::Bin/../root/static/sitemaps");
for my $file (@files) {
    if (!grep { $_ eq $file } @sitemap_files) {
        print localtime() . " removing $file\n";
        unlink "$FindBin::Bin/../root/static/sitemaps/$file";
    }
}
print localtime() . " Done\n";

sub build_one_entity {
    my ($entity_type, $index, $sql) = @_;
    my $raw_batches = $sql->select_list_of_hashes(
        "SELECT batch, count(id) from (SELECT id, ceil(id / 50000.0) AS batch FROM $entity_type) q GROUP BY batch ORDER BY batch ASC"
    );
    my @batches;
    my $batch = {count => 0, batches => []};
    for my $raw_batch (@$raw_batches) {
        if ($batch->{count} + $raw_batch->{count} <= 50000) {
            $batch->{count} = $batch->{count} + $raw_batch->{count};
            push @{$batch->{batches}}, $raw_batch->{batch};
        } else {
            push @batches, $batch;
            $batch = {count => $raw_batch->{count}, batches => [$raw_batch->{batch}]};
        }
    }
    push @batches, $batch;
    for my $batch_info (@batches) {
        build_one_sitemap($entity_type, $batch_info, $index, $sql);
    }
}

sub build_one_sitemap {
    my ($entity_type, $batch_info, $index, $sql) = @_;

    my $minimum_batch_number = min(@{ $batch_info->{batches} });
    my $filename = "sitemap-$entity_type-$minimum_batch_number.xml";
    $filename .= '.gz' if $fCompress;

    local $| = 1; # autoflush stdout
    print localtime() . " Building $filename...";

    my $local_filename = "$FindBin::Bin/../root/static/sitemaps/$filename";
    my $remote_filename = $web_server . '/' . $filename;
    my $existing_md5;

    if (-f $local_filename) {
        $existing_md5 = hash_sitemap($local_filename);
    }

    my $entity_url = $ENTITIES{$entity_type} && $ENTITIES{$entity_type}{url} || $entity_type;
    my $entity_id = $entity_type eq 'cdtoc' ? 'discid' : 'gid';

    my $map = WWW::Sitemap::XML->new();
    my $ids = $sql->select_single_column_array(
        "SELECT $entity_id FROM $entity_type WHERE ceil(id / 50000.0) = any(?) ORDER BY id ASC",
        $batch_info->{batches}
    );
    for my $id (@$ids) {
        my $url = $web_server . '/' . $entity_url . '/' . $id;
        my %add_opts = (loc => $url);
        $map->add(%add_opts);
    }
    $map->write($local_filename);
    push @sitemap_files, $filename;

    my $modtime = DateTime->now->date(); # YYYY-MM-DD
    if ($existing_md5 && $existing_md5 eq hash_sitemap($local_filename) && $old_sitemap_modtime{$remote_filename}) {
        print "using previous modtime, since file unchanged...";
        $modtime = $old_sitemap_modtime{$remote_filename};
    }

    $index->add(loc => $remote_filename, lastmod => $modtime);
    print " built.\n";
}

sub hash_sitemap {
    my ($filename) = @_;
    my $map = WWW::Sitemap::XML->new();
    $map->load( location => $filename );
    return md5_hex(join('|', map { join(',', $_->loc, $_->lastmod // '', $_->changefreq // '', $_->priority // '') } sort_by { $_->loc } $map->urls));
}
