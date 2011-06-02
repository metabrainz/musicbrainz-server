#!/usr/bin/env perl
use strict;
use warnings;

use FindBin '$Bin';
use lib "$Bin/../../../lib";

use MusicBrainz::Server::Context;
use Sql;
use URI;

my $c = MusicBrainz::Server::Context->create_script_context;
my $uri = URI->new;

my %urls;
my %redirects;
my %merge_map;

my $sql = Sql->new( $c->dbh );
printf STDERR 'Selecting public URLS';
$sql->select('SELECT * FROM public.url');
my $i = 0;
while(my $row = $sql->next_row_hash_ref) {
    my $correct_url = URI->new($row->{url})->canonical->as_string;
    if (my $official = $urls{$correct_url}) {
        $redirects{ $row->{gid} } =
	  $merge_map{ $row->{id} } =
	    $official->{id};
    }
    else {
        $row->{url} = $correct_url;
        $urls{ $correct_url } = $row;
    }
    printf "%d\r", $i++;
}

$sql->finish;

$sql->begin;

printf STDERR 'Preparing merge tables';
$sql->do("CREATE TABLE tmp_url_merge (
        old_url INTEGER NOT NULL,
        new_url INTEGER NOT NULL
    )");
$sql->do('INSERT INTO tmp_url_merge (old_url, new_url) VALUES ' .
	 join(', ', ('(?, ?)') x keys %merge_map), %merge_map);

printf STDERR 'Inserting the corrected canonical URLs';
$sql->do('TRUNCATE url CASCADE');
$sql->do('COPY url FROM STDIN');
sub escape {
    my $str = shift;
    $str =~ s/\t/\\t/g;
    $str =~ s/\n/\\n/g;
    $str =~ s/\r/\\r/g;
    $str =~ s/\\/\\\\/g;
    return $str;
}
$i = 0;
my @t = localtime(time());
my $timestamp = sprintf "%d-%d-%d %d:%02d:%02d" , $t[5] + 1900, $t[4] + 1, $t[3], $t[2], $t[1], $t[0];
for my $url (values %urls) {
    my $put = join("\t", $url->{id}, $url->{gid}, escape($url->{url}),
                   escape($url->{description}), $url->{refcount}, 0, $timestamp) . "\n";

    $sql->dbh->pg_putcopydata($put);
    printf "%d\r", $i++;
}
$sql->dbh->pg_putcopyend();

printf STDERR 'Adding GID redirections';
if (%redirects) {
  $sql->do('TRUNCATE url_gid_redirect');
  $sql->do(q{ INSERT INTO url_gid_redirect (gid, new_id) VALUES } .
	   join(", ", ("(?, ?)") x keys %redirects),
	   %redirects);
}

printf STDERR 'Merging relationships';
my @entity_types = qw(artist label recording release release_group work);
foreach my $type (@entity_types) {
    my ($entity0, $entity1, $table);
    if ($type lt "url") {
        $entity0 = "entity0";
	$entity1 = "entity1";
	$table = "l_${type}_url";
    }
    else {
        $entity0 = "entity1";
	$entity1 = "entity0";
	$table = "l_url_${type}";
    }

    printf STDERR "Merging $table";
    $sql->do("
SELECT
    DISTINCT ON (link, $entity0, COALESCE(new_url, $entity1))
        id, link, $entity0, COALESCE(new_url, $entity1) AS $entity1, edits_pending
INTO TEMPORARY tmp_$table
FROM $table
    LEFT JOIN tmp_url_merge rm ON $table.$entity1=rm.old_url;

TRUNCATE $table;
INSERT INTO $table SELECT id, link, entity0, entity1, edits_pending FROM tmp_$table;
DROP TABLE tmp_$table;
");
}

printf STDERR 'Merging l_url_url';
$sql->do("
SELECT
    DISTINCT ON (link, COALESCE(rm0.new_url, entity0), COALESCE(rm1.new_url, entity1)) id, link, COALESCE(rm0.new_url, entity0) AS entity0, COALESCE(rm1.new_url, entity1) AS entity1, edits_pending
INTO TEMPORARY tmp_l_url_url
FROM l_url_url
    LEFT JOIN tmp_url_merge rm0 ON l_url_url.entity0=rm0.old_url
    LEFT JOIN tmp_url_merge rm1 ON l_url_url.entity1=rm1.old_url
WHERE COALESCE(rm0.new_url, entity0) != COALESCE(rm1.new_url, entity1);

TRUNCATE l_url_url;
INSERT INTO l_url_url SELECT * FROM tmp_l_url_url;
DROP TABLE tmp_l_url_url;
");

$sql->commit;
