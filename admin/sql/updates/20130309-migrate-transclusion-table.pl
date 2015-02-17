#!/usr/bin/perl
use strict;
use warnings;

use MusicBrainz::Server::Context;
use DBDefs;

my $c = MusicBrainz::Server::Context->create_script_context;

my $index = _load_index_from_disk();

my $query = 'INSERT INTO wikidocs.wikidocs_index (page_name, revision) VALUES ';
$query .= join(', ', ("(?, ?)") x keys %$index);
my @args = map { $_, $index->{$_} } keys %$index;

Sql::run_in_transaction(sub {
    $c->sql->do($query, @args);
}, $c->sql);

sub _parse_index
{
    my ($data) = @_;

    my %index;
    foreach my $line (split(/\n/, $data)) {
        my ($page, $version) = split(/=/, $line);
        $index{$page} = $version;
    }
    return \%index;
}

sub _load_index_from_disk
{
    my $index_file = DBDefs->STATIC_FILES_DIR . '/wikidocs/index.txt';
    if (!open(FILE, "<" . $index_file)) {
        warn "Could not open wikitrans index file '$index_file': $!.";
        return {};
    }
    my $data = do { local $/; <FILE> };
    close(FILE);

    return _parse_index($data);
}
