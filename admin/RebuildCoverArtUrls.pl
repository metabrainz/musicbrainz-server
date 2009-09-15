#!/usr/bin/perl -w

use FindBin;
use lib "$FindBin::Bin/../lib";

use Sql;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::CoverArt;

# ALTER TABLE release_meta ADD coverarturl VARCHAR(255);
# ALTER TABLE release_meta ADD infourl VARCHAR(255);
# ALTER TABLE release_meta ADD amazonasin VARCHAR(10);
# ALTER TABLE release_meta ADD amazonstore VARCHAR(20);

my $c = MusicBrainz::Server::Context->new();

my $rw_sql = Sql->new($c->dbh);
my $sql = Sql->new($c->dbh);


my $amazon_update_query = "
    UPDATE release_meta
    SET coverarturl=?, amazonasin=?, amazonstore=? WHERE id=?";

my $coverart_update_query = "
    UPDATE release_meta
    SET coverarturl=?, infourl=? WHERE id=?";

$rw_sql->begin;

printf STDERR "Amazon URLs\n";
my $query = "
    SELECT url.url, l.entity0 AS id
    FROM l_release_url l
        JOIN link ON l.link=link.id
        JOIN link_type ON link.link_type=link_type.id
        JOIN url ON l.entity1=url.id
    WHERE link_type.name='amazon asin'
";
$sql->select($query);
my $cnt = 0;
while (1) {
    my $row = $sql->next_row_hash_ref or last;
    my ($asin, $coverarturl, $store) = MusicBrainz::Server::CoverArt->ParseAmazonURL($row->{url});
    next unless $coverarturl;
    $rw_sql->do($amazon_update_query, $coverarturl || undef, $asin || undef, $store || undef, $row->{id});
    if ($cnt++ % 10 == 0) {
        printf STDERR "%d/%d\r", $cnt, $sql->row_count;
    }
}
$sql->finish;

printf STDERR "Cover art URLs\n";
$query = "
    SELECT url.url, l.entity0 AS id
    FROM l_release_url l
        JOIN link ON l.link=link.id
        JOIN link_type ON link.link_type=link_type.id
        JOIN url ON l.entity1=url.id
    WHERE link_type.name='cover art link'
";
$sql->select($query);
$cnt = 0;
while (1) {
    my $row = $sql->next_row_hash_ref or last;
    my ($name, $coverarturl, $infourl) = MusicBrainz::Server::CoverArt->ParseCoverArtURL($row->{url});
    next unless $coverarturl;
    $rw_sql->do($coverart_update_query, $coverarturl || undef, $infourl || undef, $row->{id});
    if ($cnt++ % 10 == 0) {
        printf STDERR "%d/%d\r", $cnt, $sql->row_count;
    }
}
$sql->finish;

$rw_sql->commit;
