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

my $sql = Sql->new( $c->dbh );
log_trace { 'Selecting public URLS' };
$sql->select('SELECT * FROM public.url');
while(my $row = $sql->next_row_hash_ref) {
    my $correct_url = URI->new($row->{url})->canonical->as_string;
    if (my $official = $urls{$correct_url}) {
        $redirects{ $row->{gid} } = $official->{id};
    }
    else {
        $row->{url} = $correct_url;
        $urls{ $correct_url } = $row;
    }
}

$sql->finish;

$sql->begin;

my @inserts = values %urls;
$sql->do(q{ INSERT INTO url (id, gid, url, description, refcount) VALUES } .
	 join(", ", ("(?, ?, ?, ?, ?)") x @inserts),
	map {
	  $_->{id}, $_->{gid}, $_->{url}, $_->{description},
	  $_->{refcount}
	} @inserts);

if (%redirects) {
  $sql->do(q{ INSERT INTO url_gid_redirect (gid, newid) VALUES } .
	   join(", ", ("(?, ?)") x keys %redirects),
	   %redirects);
}

$sql->commit;
