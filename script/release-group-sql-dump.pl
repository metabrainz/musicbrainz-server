#!/usr/bin/perl

use strict;
use warnings;
use feature "switch";
use DBI;
use Data::Dumper;

my $schema = 'musicbrainz';
my $test_schema = 'musicbrainz_test';
my %insert_dupe_check;
my %artist_dupe_check;
my @backup;

sub quote_column
{
    my ($type, $data) = @_;

    return "NULL" unless defined $data;

    die "no type" unless defined $type;

    my $ret;

    given ($type) {
        when (/^integer\[\]/) { $ret = "'{" . join(",", @$data) . "}'"; }
        when (/^integer/) { $ret = $data; }
        when (/^smallint/) { $ret = $data; }
        default { 
            $data =~ s/'/''/;
            $ret = "'$data'"; 
        }
    }

    return $ret;
}

sub insert
{
    my ($dbh, $table, $data, $commit) = @_;

    return 0 unless keys %$data;

    my @values;
    while (my ($key, $val) = each (%$data))
    {
        my $col = $dbh->column_info (undef, $schema, $table, $key)->fetchrow_hashref;

        push @values, quote_column ($col->{pg_type}, $val);
    }

    my $cmd = "INSERT INTO $table (".join (", ", keys %$data).") ".
        "VALUES (".join (", ", @values).");";

    $insert_dupe_check{$table} = {} unless $insert_dupe_check{$table};

    return 0 if $insert_dupe_check{$table}->{$cmd};

    $insert_dupe_check{$table}->{$cmd} = 1;
    push @backup, $cmd;

    return $cmd;
}

sub query
{
    my ($dbh, $table, $query) = @_;

    my @results;
    my @inserted;

    @results = @{ $dbh->selectall_arrayref($query, { Slice => {} }) };

    return \@results;
}

sub backup
{
    my ($dbh, $table, $results) = @_;

    my @inserted;

    for (@$results)
    {
        my $tmp = insert ($dbh, $table, $_);
        push @inserted, $tmp if $tmp;
    }

    return scalar @inserted ? $results : 0;
}

sub get_rows
{
    my ($dbh, $table, $key, $value) = @_;

    my $col = $dbh->column_info (undef, $schema, $table, $key)->fetchrow_hashref;
    my $quoted = quote_column ($col->{pg_type}, $value);

    return query ($dbh, $table, "SELECT * FROM $table WHERE $key = $quoted");
}

sub generic
{
    my ($dbh, $table, $col, $key) = @_;

    my $data = get_rows ($dbh, $table, $col, $key);
    backup ($dbh, $table, $data);
}

sub generic_verbose
{
    my ($dbh, $table, $col, $key) = @_;

    my $data = get_rows ($dbh, $table, $col, $key);
    backup ($dbh, $table, $data);

    print "Exporting ".$data->[0]->{name}." ($table)\n";
}

sub artist
{
    my ($dbh, $id) = @_;

    return $artist_dupe_check{$id} if $artist_dupe_check{$id};

    my $data = get_rows ($dbh, 'artist', 'id', $id);

    generic_verbose ($dbh, 'artist_name', 'id', $data->[0]->{name});
    generic_verbose ($dbh, 'artist_name', 'id', $data->[0]->{sortname});
    generic ($dbh, 'artist_type', 'id', $data->[0]->{type});

    backup ($dbh, 'artist', $data);

    artist_alias ($dbh, $data->[0]->{id});

    $artist_dupe_check{$id} = $data;
    # country
    # type
    # gender
}

sub artist_alias
{
    my ($dbh, $id) = @_;

    my $data = get_rows ($dbh, 'artist_alias', 'artist', $id);
    for (@$data)
    {
        generic ($dbh, 'artist_name', 'id', $_->{name});
    }
    backup ($dbh, 'artist_alias', $data);
}

sub artist_credit_name
{
    my ($dbh, $id) = @_;

    my $data = get_rows ($dbh, 'artist_credit_name', 'artist_credit', $id);
    for (@$data)
    {
        generic ($dbh, 'artist_name', 'id', $_->{name});
        artist ($dbh, $_->{artist});
    }
    backup ($dbh, 'artist_credit_name', $data);
}

sub artist_credit
{
    my ($dbh, $id) = @_;

    my $tmp = get_rows ($dbh, 'artist_credit', 'id', $id);
    return unless $tmp;
    my $data = $tmp->[0];

    generic ($dbh, 'artist_name', 'id', $data->{name});
    backup ($dbh, 'artist_credit', $tmp);
    artist_credit_name ($dbh, $id);
}

sub recording
{
    my ($dbh, $id) = @_;

    my $data = get_rows ($dbh, 'recording', 'id', $id);
    generic_verbose ($dbh, 'track_name', 'id', $data->[0]->{name});
    artist_credit ($dbh, $data->[0]->{artist_credit});
    backup ($dbh, 'recording', $data);
}

sub tracks
{
    my ($dbh, $id) = @_;

    my $data = get_rows ($dbh, 'track', 'tracklist', $id);
    for (@$data)
    {
        generic ($dbh, 'track_name', 'id', $_->{name});
        recording ($dbh, $_->{recording});
        artist_credit ($dbh, $_->{artist_credit});
    }
    backup ($dbh, 'track', $data);
}

sub tracklists
{
    my ($dbh, $id) = @_;

    my $data = get_rows ($dbh, 'tracklist', 'id', $id);
    backup ($dbh, 'tracklist', $data);

    tracks ($dbh, $id);
}

sub medium_cdtocs
{
    my ($dbh, $id) = @_;

    my $data = get_rows ($dbh, 'medium_cdtoc', 'medium', $id);
    for (@$data)
    {
        generic ($dbh, 'cdtoc', 'id', $_->{cdtoc});
    }
    backup ($dbh, 'medium_cdtoc', $data);
}

sub media
{
    my ($dbh, $id) = @_;

    my $data = get_rows ($dbh, 'medium', 'release', $id);
    
    for (@$data)
    {
        generic ($dbh, 'medium_format', 'id', $_->{format});
        tracklists ($dbh, $_->{tracklist});
        medium_cdtocs ($dbh, $_->{id});
    }

    backup ($dbh, 'medium', $data);
}

sub label_alias
{
    my ($dbh, $id) = @_;

    my $data = get_rows ($dbh, 'label_alias', 'label', $id);
    for (@$data)
    {
        generic ($dbh, 'label_name', 'id', $_->{name});
    }
    backup ($dbh, 'label_alias', $data);
}

sub label
{
    my ($dbh, $id) = @_;

    my $data = get_rows ($dbh, 'label', 'id', $id);

    generic ($dbh, 'label_type', 'id', $data->[0]->{type});
    generic_verbose ($dbh, 'label_name', 'id', $data->[0]->{name});
    backup ($dbh, 'label', $data);
    label_alias ($dbh, $data->[0]->{id});
}


sub release_label
{
    my ($dbh, $id) = @_;

    my $data = get_rows ($dbh, 'release_label', 'release', $id);
    for (@$data)
    {
        label ($dbh, $_->{label});
    }
    backup ($dbh, 'release_label', $data);
}

sub releases
{
    my ($dbh, $id) = @_;

    my $data = get_rows ($dbh, 'release', 'release_group', $id);

    for (@$data)
    {
        generic ($dbh, 'release_status', 'id', $_->{status});
        generic ($dbh, 'country', 'id', $_->{country});
        generic ($dbh, 'language', 'id', $_->{language});
        generic ($dbh, 'script', 'id', $_->{script});
        generic_verbose ($dbh, 'release_name', 'id', $_->{name});
        artist_credit ($dbh, $_->{artist_credit});
    }

    backup ($dbh, 'release', $data);

    for (@$data)
    {
        media ($dbh, $_->{id});
        release_label ($dbh, $_->{id});
    }

}

sub release_group
{
    my ($dbh, $gid) = @_;

    my $tmp = get_rows ($dbh, 'release_group', 'gid', $gid);
    my $data = $tmp->[0];

    generic ($dbh, 'release_group_type', 'id', $data->{type});
    generic_verbose ($dbh, 'release_name', 'id', $data->{name});
    artist_credit ($dbh, $data->{artist_credit});

    backup ($dbh, 'release_group', $tmp);

    releases ($dbh, $data->{id});
}


sub main
{
    my $outputfile = shift;
    my $dbh = DBI->connect("dbi:Pg:dbname=musicbrainz", "warp", "");

    $dbh->do ("SET search_path TO $schema");

    foreach (@ARGV) {
        release_group ($dbh, $_);
    }

    print "Writing output to $outputfile ...\n";
    open (DUMP, ">$outputfile");

    print DUMP "BEGIN;\n";
    print DUMP "SET client_min_messages TO 'warning';\n";
    print DUMP "SET search_path TO $test_schema;\n\n";

    my %truncated;
    foreach (@backup)
    {
        (my $truncate = $_) =~ s/INSERT INTO ([^ ]*) .*/TRUNCATE $1 CASCADE;/;

        next if $truncated{$truncate};
        print DUMP "$truncate\n";
        $truncated{$truncate} = 1;
    }

    print DUMP "\n";

    foreach (@backup)
    {
        print DUMP "$_\n";
    }

    print DUMP "\nCOMMIT;\n\n";
    close (DUMP);

    print "Done!\n";
}

main (shift);
