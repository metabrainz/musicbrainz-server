#!/usr/bin/perl
use strict;
use warnings;

use FindBin '$Bin';
use lib "$Bin/../../../lib";

use Log::Contextual::SimpleLogger;
use Log::Contextual qw( :log :dlog ),
  -default_logger => Log::Contextual::SimpleLogger->new({
							 levels => [qw( info debug  trace)]
							});

log_info { 'Merging URLs with differing encodings' };

use MusicBrainz::Server::Context;
use Sql;
use URI;

my $c = MusicBrainz::Server::Context->create_script_context;
my $uri = URI->new;

my %urls;
my %redirects;
my %merge_map;

my $sql = Sql->new( $c->dbh );
log_trace { 'Selecting public URLS' };
$sql->select('SELECT * FROM public.url');
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
}

$sql->finish;

$sql->begin;

log_trace { 'Preparing merge tables' };
$sql->do("CREATE TABLE tmp_url_merge (
        old_url INTEGER NOT NULL,
        new_url INTEGER NOT NULL
    )");
$sql->do('INSERT INTO tmp_url_merge (old_url, new_url) VALUES ' .
	 join(', ', ('(?, ?)') x keys %merge_map), %merge_map);

log_trace { 'Inserting the correct URLs' };
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
for my $url (values %urls) {
    my $put = join("\t", $url->{id}, $url->{gid}, escape($url->{url}),
                   escape($url->{description}), $url->{refcount}, 0) . "\n";
    log_trace { "Putting $put" };

    $sql->dbh->pg_putcopydata($put);
}
$sql->dbh->pg_putcopyend();

log_trace { 'Adding GID redirections' };
if (%redirects) {
  $sql->do('TRUNCATE url_gid_redirect');
  $sql->do(q{ INSERT INTO url_gid_redirect (gid, newid) VALUES } .
	   join(", ", ("(?, ?)") x keys %redirects),
	   %redirects);
}

log_trace { 'Merging relationships' };
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

    log_trace { "Merging $table" };
    $sql->do("
SELECT
    DISTINCT ON (link, $entity0, COALESCE(new_url, $entity1))
        id, link, $entity0, COALESCE(new_url, $entity1) AS $entity1, editpending
INTO TEMPORARY tmp_$table
FROM $table
    LEFT JOIN tmp_url_merge rm ON $table.$entity1=rm.old_url;

TRUNCATE $table;
INSERT INTO $table SELECT id, link, entity0, entity1, editpending FROM tmp_$table;
DROP TABLE tmp_$table;
");
}

log_trace { 'Merging l_url_url' };
$sql->do("
SELECT
    DISTINCT ON (link, COALESCE(rm0.new_url, entity0), COALESCE(rm1.new_url, entity1)) id, link, COALESCE(rm0.new_url, entity0) AS entity0, COALESCE(rm1.new_url, entity1) AS entity1, editpending
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
