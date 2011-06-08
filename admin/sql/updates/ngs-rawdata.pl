#!/usr/bin/env perl

use warnings;

use strict;
use FindBin;
use lib "$FindBin::Bin/../../../lib";

use DBDefs;
use MusicBrainz::Server::Data::Utils qw( placeholders );
use MusicBrainz::Server::Validation;
use Sql;

use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';

my $mb = Databases->get_connection('READWRITE');
my $sql = Sql->new($mb->dbh);

my $raw_mb = Databases->get_connection('RAWDATA');
my $raw_sql = Sql->new($raw_mb->dbh);

$sql->begin;
$raw_sql->begin;
eval {

print "Converting artist data\n";

$raw_sql->do("
    INSERT INTO artist_rating_raw (artist, editor, rating)
        SELECT artist, editor, rating * 20 FROM public.artist_rating_raw
    ");

$raw_sql->do("
    INSERT INTO artist_tag_raw (artist, editor, tag)
        SELECT artist, moderator, tag FROM public.artist_tag_raw
    ");

print "Converting label data\n";

$raw_sql->do("
    INSERT INTO label_rating_raw (label, editor, rating)
        SELECT label, editor, rating * 20 FROM public.label_rating_raw
    ");

$raw_sql->do("
    INSERT INTO label_tag_raw (label, editor, tag)
        SELECT label, moderator, tag FROM public.label_tag_raw
    ");

print "Converting recording data\n";

$raw_sql->do("
    INSERT INTO recording_rating_raw (recording, editor, rating)
        SELECT track, editor, rating * 20 FROM public.track_rating_raw
    ");

$raw_sql->do("
    INSERT INTO recording_tag_raw (recording, editor, tag)
        SELECT track, moderator, tag FROM public.track_tag_raw
    ");

print "Converting release group data\n";


print " * Loading release group map\n";
my $albums = $sql->select_list_of_hashes("SELECT id, release_group FROM public.album");
my %rg_map = map { $_->{id} => $_->{release_group} } @$albums;
$albums = undef;

$raw_sql->do("CREATE AGGREGATE array_accum (basetype = anyelement, sfunc = array_append, stype = anyarray, initcond = '{}')");

print " * Converting raw tags\n";
my %aggr;
$raw_sql->select("
    SELECT tag, moderator, array_accum(release)
    FROM public.release_tag_raw
    GROUP BY tag, moderator");
while (1) {
    my $row = $raw_sql->next_row_ref or last;
    my ($tag, $editor, $ids) = @$row;
    # Unpack the array if using old DBD::Pg
    if (ref $ids ne 'ARRAY') {
        $ids = [ $ids =~ /(\d+)/g ];
    }
    # Map album ids to release_group ids, remove duplicates
    my %ids = map { $rg_map{$_} => 1 } @$ids;
    my @ids = keys %ids;
    foreach my $id (@ids) {
        $raw_sql->do("
            INSERT INTO release_group_tag_raw (release_group, editor, tag)
            VALUES (?, ?, ?)", $id, $editor, $tag);
        unless (exists $aggr{$id}) {
            $aggr{$id} = {};
        }
        if (exists $aggr{$id}{$tag}) {
            $aggr{$id}->{$tag} += 1;
        }
        else {
            $aggr{$id}->{$tag} = 1;
        }
    }
}
$raw_sql->finish;

print " * Converting aggregated tags\n";
foreach my $id (keys %aggr) {
    my %tags = %{ $aggr{$id} };
    foreach my $tag (keys %tags) {
        $sql->do("
            INSERT INTO release_group_tag (release_group, tag, count)
            VALUES (?, ?, ?)", $id, $tag, $tags{$tag});
    }
}
%aggr = ();

print " * Converting raw ratings\n";
# Iterate over all raw ratings
$raw_sql->select("
    SELECT rating * 20, editor, release
    FROM public.release_rating_raw
    ORDER BY editor");
my $user_id = 0;
my @user_data;
while (1) {
    my $row = $raw_sql->next_row_ref;
    my $new_user_id = $row ? $row->[1] : 0;
    if ($user_id != $new_user_id) {
        # If this is a new user, process their ratings
        if (@user_data) {
            my %rg_rating_sum;
            my %rg_rating_cnt;
            # Map albums to RGs and calculate sums/counts
            foreach $row (@user_data) {
                my ($rating, $editor, $album) = @$row;
                my $rg = $rg_map{$album} or next;
                $rg_rating_sum{$rg} += $rating;
                $rg_rating_cnt{$rg} += 1;
            }
            # Iterate over unique RGs and add average raw ratings
            foreach my $rg (keys %rg_rating_sum) {
                next unless defined $rg;
                my $rating = int(0.5 + $rg_rating_sum{$rg} / $rg_rating_cnt{$rg});
                $raw_sql->do("
                    INSERT INTO release_group_rating_raw (release_group, editor, rating)
                    VALUES (?, ?, ?)", $rg, $user_id, $rating);
            }
        }
        $user_id = $new_user_id;
        @user_data = ();
    }
    last if !$new_user_id;
    push @user_data, [ @$row ];
}
%rg_map = ();

print " * Converting average ratings\n";
$sql->do("CREATE UNIQUE INDEX tmp_release_group_meta_idx ON release_group_meta (id)");
$raw_sql->select("
    SELECT release_group, avg(rating)::INT, count(*)
    FROM release_group_rating_raw
    GROUP BY release_group");
while (1) {
    my $row = $raw_sql->next_row_ref or last;
    my ($id, $rating, $count) = @$row;
    $sql->do("UPDATE release_group_meta SET rating=?, rating_count=? WHERE id=?", $rating, $count, $id);
}
$raw_sql->finish;
$sql->do("DROP INDEX tmp_release_group_meta_idx");

$raw_sql->do("DROP AGGREGATE array_accum (anyelement)");

print " * Converting CD stubs\n";
$raw_sql->do("INSERT INTO cdtoc_raw SELECT * FROM public.cdtoc_raw");
$raw_sql->do("INSERT INTO release_raw SELECT * FROM public.release_raw");
$raw_sql->do("INSERT INTO track_raw SELECT * FROM public.track_raw");

print " * Loading album->release map\n";

$sql->select("
    SELECT a.id, r.id AS release
    FROM release r
        JOIN public.album a ON a.gid::uuid = r.gid
");
my %release_map;
while (1) {
    my $row = $sql->next_row_ref or last;
    $release_map{ $row->[0] } = $row->[1];
}
$sql->finish;

print " * Converting collections\n";

$raw_sql->select("SELECT id, moderator FROM public.collection_info");
while (1) {
    my $row = $raw_sql->next_row_ref or last;
    my ($id, $editor_id) = @$row;
    # List should be private by default, and called "My Collection"
    $sql->do("INSERT INTO editor_collection (id, editor, name, public, gid) VALUES (?, ?, ?, ?, generate_uuid_v4())",
             $id, $editor_id, "My Collection", 0);
}
$raw_sql->finish;

$raw_sql->select("SELECT collection_info, album
                  FROM public.collection_has_release_join");
while (1) {
    my $row = $raw_sql->next_row_ref or last;
    my ($list_id, $album_id) = @$row;
    next unless $release_map{$album_id};
    $sql->do("INSERT INTO editor_collection_release (collection, release)
              VALUES (?, ?)", $list_id, $release_map{$album_id});
}
$raw_sql->finish;

$raw_sql->select(
    'SELECT moderator, artist
       FROM public.collection_watch_artist_join watch
       JOIN public.collection_info ci ON ci.id = collection_info');
while (my $row = $raw_sql->next_row_hash_ref) {
    $sql->do('INSERT INTO editor_watch_artist (editor, artist)
        VALUES (?, ?)', $row->{moderator}, $row->{artist});
}
$raw_sql->finish;

$sql->do('DELETE FROM editor_watch_artist WHERE artist IN(
    SELECT artist FROM editor_watch_artist
 LEFT JOIN artist on artist.id = artist
     WHERE artist.id IS NULL
)');

use DateTime::Duration;
use DateTime::Format::Pg;

my $format = DateTime::Format::Pg->new;

$raw_sql->select('SELECT * FROM public.collection_info');
while (my $row = $raw_sql->next_row_hash_ref) {
    $sql->do("INSERT INTO editor_watch_preferences
        (editor, notify_via_email, notification_timeframe, last_checked)
            VALUES (?, ?, ?, NOW() - '@ 1 year'::INTERVAL)",
        $row->{moderator}, $row->{emailnotifications},
        $format->format_interval(
            DateTime::Duration->new( days => $row->{notificationinterval} )));

    my @attributes = @{ $row->{ignoreattributes} };
    my @types = grep { $_ < 100 } @attributes;
    my @status = map { $_ - 99 } grep { $_ >= 100 } @attributes;

    $sql->do(
        'INSERT INTO editor_watch_release_group_type
            (editor, release_group_type)
                SELECT ?, id
                  FROM release_group_type
                 WHERE id NOT IN (' . placeholders(@types) . ')',
        $row->{moderator}, @types) if @types;

    $sql->do(
        'INSERT INTO editor_watch_release_status
            (editor, release_status)
                SELECT ?, id
                  FROM release_status
                 WHERE id NOT IN (' . placeholders(@status) . ')',
        $row->{moderator}, @status) if @status;
}
$raw_sql->finish;

$sql->do(
    "INSERT INTO editor_watch_preferences (editor, notify_via_email, notification_timeframe)
         SELECT id, FALSE, '@ 1 week'::INTERVAL
           FROM editor
          WHERE id NOT IN (SELECT editor FROM editor_watch_preferences)"
);

    $sql->commit;
    $raw_sql->commit;
};
if ($@) {
    printf STDERR "ERROR: %s\n", $@;
    $sql->rollback;
    $raw_sql->rollback;
}
