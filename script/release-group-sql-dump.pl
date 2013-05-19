#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use feature 'switch';

use Carp qw( croak );
use DBI;
use DBDefs;
use MusicBrainz::Server::Test::Connector;

use aliased 'MusicBrainz::Server::DatabaseConnectionFactory' => 'Databases';


my $readwrite = Databases->get('READWRITE');
my $schema = 'musicbrainz';

my %insert_dupe_check;
my %artist_dupe_check;
my @backup;
my %core_entities = (
    'artist' => {},
    'label' => {},
    'recording' => {},
    'release' => {},
    'release-group' => {},
    'work' => {},
);

sub quote_column
{
    my ($type, $data) = @_;

    return "NULL" unless defined $data;

    croak "no type" unless defined $type;

    my $ret;

   given ($type) {
        when (/^integer\[\]/) { $ret = "'{" . join(",", @$data) . "}'"; }
        when (/^integer/) { $ret = $data; }
        when (/^smallint/) { $ret = $data; }
        default {
            $data =~ s/'/''/g;
            $ret = "'$data'";
        }
    }

    return $ret;
}

sub insert
{
    my ($dbh, $table, $data) = @_;

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

sub update
{
    my ($dbh, $table, $data, $primary) = @_;

    return 0 unless keys %$data;

    my $where;
    my @columns;
    while (my ($key, $val) = each (%$data))
    {
        my $col = $dbh->column_info (undef, $schema, $table, $key)->fetchrow_hashref;

        if ($key eq $primary)
        {
            $where = "$key = ".quote_column ($col->{pg_type}, $val);
        }
        else
        {
            push @columns, "$key = ".quote_column ($col->{pg_type}, $val);
        }
    }

    my $cmd = "UPDATE $table SET ".join (", ", @columns)." WHERE $where;";

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

sub get_rows_two_keys
{
    my ($dbh, $table, $key0, $value0, $key1, $values1) = @_;

    return [] unless scalar @$values1;

    my $col0 = $dbh->column_info (undef, $schema, $table, $key0)->fetchrow_hashref;
    my $col1 = $dbh->column_info (undef, $schema, $table, $key1)->fetchrow_hashref;

    return [] unless $col0 && $col1;

    my $quoted0 = quote_column ($col0->{pg_type}, $value0);
    my @quoted1;
    for (@$values1)
    {
        push @quoted1, quote_column ($col1->{pg_type}, $_);
    }
    my $quoted1 = join (", ", @quoted1);

    return query ($dbh, $table, "SELECT * FROM $table WHERE $key0 = $quoted0 AND $key1 IN ($quoted1)");
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

sub _meta
{
    my ($dbh, $table, $col, $key) = @_;

    my $data = get_rows ($dbh, $table, $col, $key);

    my @inserted;
    for (@$data)
    {
        my $tmp = update ($dbh, $table, $_, 'id');
        push @inserted, $tmp if $tmp;
    }

    return scalar @inserted ? $data : 0;
}

sub _tag
{
    my ($dbh, $table, $col, $key) = @_;

    my $data = get_rows ($dbh, $table, $col, $key);
    for (@$data)
    {
        generic_verbose ($dbh, 'tag', 'id', $_->{tag});
    }

    backup ($dbh, $table, $data);
}

sub link_attribute_type
{
    my ($dbh, $key) = @_;


    my $data = get_rows ($dbh, 'link_attribute_type', 'id', $key);

    if ($data->[0]->{parent})
    {
        link_attribute_type ($dbh, $data->[0]->{parent});
    }

    if ($data->[0]->{root} && $data->[0]->{root} != $key)
    {
        link_attribute_type ($dbh, $data->[0]->{root});
    }

    backup ($dbh, 'link_attribute_type', $data);
}

sub link_attribute
{
    my ($dbh, $key) = @_;

    my $data = get_rows ($dbh, 'link_attribute', 'link', $key);
    for (@$data)
    {
        link_attribute_type ($dbh, $_->{attribute_type});
    }
    backup ($dbh, 'link_attribute', $data);
}


sub link_type_attribute_type
{
    my ($dbh, $key) = @_;

    my $data = get_rows ($dbh, 'link_type_attribute_type', 'link_type', $key);

    for (@$data)
    {
        link_attribute_type ($dbh, $_->{attribute_type});
    }
    backup ($dbh, 'link_type_attribute_type', $data);
}

sub link_type
{
    my ($dbh, $key) = @_;

    my $data = get_rows ($dbh, 'link_type', 'id', $key);

    if ($data->[0]->{parent})
    {
        link_type ($dbh, $data->[0]->{parent});
    }

    backup ($dbh, 'link_type', $data);
    link_type_attribute_type ($dbh, $key);
}

sub l_entity_url
{
    my ($dbh, $type0, $key0) = @_;

    $type0 =~ s/-/_/g;

    my $table = 'l_'.$type0.'_url';

    my $data = get_rows ($dbh, $table, 'entity0', $key0);
    return 0 unless $data;

    for my $row (@$data)
    {
        generic ($dbh, 'url', 'id', $row->{entity1});

        my $link = get_rows ($dbh, 'link', 'id', $row->{link});

        link_type ($dbh, $link->[0]->{link_type});
        backup ($dbh, 'link', $link);
        link_attribute ($dbh, $row->{link});
    }

    backup ($dbh, $table, $data);
    return scalar @$data;
}

sub l_entity_work
{
    my ($dbh, $type0, $key0) = @_;

    $type0 =~ s/-/_/g;

    my $table = 'l_'.$type0.'_work';

    my $data = get_rows ($dbh, $table, 'entity0', $key0);
    return 0 unless $data;

    for my $row (@$data)
    {
        work ($dbh, $row->{entity1});

        my $link = get_rows ($dbh, 'link', 'id', $row->{link});

        link_type ($dbh, $link->[0]->{link_type});
        backup ($dbh, 'link', $link);
        link_attribute ($dbh, $row->{link});
    }

    backup ($dbh, $table, $data);
    return scalar @$data;
}

sub l_
{
    my ($dbh, $type0, $type1, $key0, $key1) = @_;

    $type0 =~ s/-/_/g;
    $type1 =~ s/-/_/g;

    my $table = 'l_'.$type0.'_'.$type1;

    my $data = get_rows_two_keys ($dbh, $table, 'entity0', $key0, 'entity1', $key1);
    return 0 unless $data;

    for my $row (@$data)
    {
        my $link = get_rows ($dbh, 'link', 'id', $row->{link});

        link_type ($dbh, $link->[0]->{link_type});
        backup ($dbh, 'link', $link);
        link_attribute ($dbh, $row->{link});
    }

    backup ($dbh, $table, $data);
    return scalar @$data;
}

sub artist
{
    my ($dbh, $id) = @_;

    return $artist_dupe_check{$id} if $artist_dupe_check{$id};

    $core_entities{artist}{$id} = 1;

    my $data = get_rows ($dbh, 'artist', 'id', $id);

    generic_verbose ($dbh, 'artist_name', 'id', $data->[0]->{name});
    generic_verbose ($dbh, 'artist_name', 'id', $data->[0]->{sort_name});
    generic ($dbh, 'artist_type', 'id', $data->[0]->{type});
    generic ($dbh, 'gender', 'id', $data->[0]->{gender});
    generic ($dbh, 'country', 'id', $data->[0]->{country});

    backup ($dbh, 'artist', $data);

    artist_alias ($dbh, $data->[0]->{id});

    _meta ($dbh, 'artist_meta', 'id', $id);
    _tag ($dbh, 'artist_tag', 'artist', $id);

    $artist_dupe_check{$id} = $data;
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

    $core_entities{recording}{$id} = 1;

    my $data = get_rows ($dbh, 'recording', 'id', $id);
    generic_verbose ($dbh, 'track_name', 'id', $data->[0]->{name});
    artist_credit ($dbh, $data->[0]->{artist_credit});
    backup ($dbh, 'recording', $data);

    recording_puid ($dbh, $id);
    generic ($dbh, 'isrc', 'recording', $id);

    _meta ($dbh, 'recording_meta', 'id', $id);
    _tag ($dbh, 'recording_tag', 'recording', $id);
}

sub recording_puid
{
    my ($dbh, $id) = @_;

    my $data = get_rows ($dbh, 'recording_puid', 'recording', $id);
    for (@$data)
    {
        puid ($dbh, $_->{puid});
    }
    backup ($dbh, 'recording_puid', $data);
}

sub puid
{
    my ($dbh, $id) = @_;

    my $data = get_rows ($dbh, 'puid', 'id', $id);

    generic ($dbh, 'clientversion', 'id', $data->[0]->{version});
    backup ($dbh, 'puid', $data);
}

sub tracks
{
    my ($dbh, $id) = @_;

    my $data = get_rows ($dbh, 'track', 'medium', $id);

    for (@$data)
    {
        generic ($dbh, 'track_name', 'id', $_->{name});
        recording ($dbh, $_->{recording});
        artist_credit ($dbh, $_->{artist_credit});
    }
    backup ($dbh, 'track', $data);
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
    }

    backup ($dbh, 'medium', $data);

    for (@$data)
    {
        medium_cdtocs ($dbh, $_->{id});
        tracks ($dbh, $_->{id});
    }
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

    $core_entities{label}{$id} = 1;

    my $data = get_rows ($dbh, 'label', 'id', $id);

    generic ($dbh, 'label_type', 'id', $data->[0]->{type});
    generic_verbose ($dbh, 'label_name', 'id', $data->[0]->{name});
    backup ($dbh, 'label', $data);
    label_alias ($dbh, $data->[0]->{id});

    _meta ($dbh, 'label_meta', 'id', $id);
    _tag ($dbh, 'label_tag', 'label', $id);
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

    _meta ($dbh, 'release_meta', 'id', $id);
}

sub releases
{
    my ($dbh, $id) = @_;

    my $data = get_rows ($dbh, 'release', 'release_group', $id);

    for (@$data)
    {
        $core_entities{release}{$_->{id}} = 1;

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

    $core_entities{'release-group'}{$data->{id}} = 1;

    generic ($dbh, 'release_group_primary_type', 'id', $data->{type});
    generic_verbose ($dbh, 'release_name', 'id', $data->{name});
    artist_credit ($dbh, $data->{artist_credit});

    backup ($dbh, 'release_group', $tmp);

    releases ($dbh, $data->{id});

    _meta ($dbh, 'release_group_meta', 'id', $data->{id});
    _tag ($dbh, 'release_group_tag', 'release_group', $data->{id});
}

sub work
{
    my ($dbh, $id) = @_;

    $core_entities{work}{$id} = 1;

    my $data = get_rows ($dbh, 'work', 'id', $id);

    generic ($dbh, 'work_type', 'id', $data->[0]->{type});
    generic_verbose ($dbh, 'work_name', 'id', $data->[0]->{name});
    artist_credit ($dbh, $data->[0]->{artist_credit});
    backup ($dbh, 'work', $data);

    _meta ($dbh, 'work_meta', 'id', $id);
    _tag ($dbh, 'work_tag', 'work', $id);
}


sub rel_entity_entity
{
    my ($dbh, $type0, $type1) = @_;

    my $count = 0;

    for my $entity0 (keys %{ $core_entities{$type0} })
    {
        my @linked = keys %{ $core_entities{$type1} };
        $count += l_ ($dbh, $type0, $type1, $entity0, \@linked)
    }

    warn "Exported $count $type0 -> $type1 relationships.\n" if $count;
}

sub rel_entity_url
{
    my ($dbh, $type0) = @_;

    return if $type0 eq 'work';

    my $count = 0;

    for my $entity0 (keys %{ $core_entities{$type0} })
    {
        $count += l_entity_url ($dbh, $type0, $entity0)
    }

    warn "Exported $count $type0 -> url relationships.\n" if $count;
}

sub rel_entity_work
{
    my ($dbh, $type0) = @_;

    return unless $type0 eq 'recording' || $type0 eq 'release';

    my $count = 0;

    for my $entity0 (keys %{ $core_entities{$type0} })
    {
        $count += l_entity_work ($dbh, $type0, $entity0)
    }

    warn "Exported $count $type0 -> work relationships.\n" if $count;
}

sub relationships
{
    my $dbh = shift;

    my @entities = keys %core_entities;
    for my $type0 (@entities)
    {
        for my $type1 (@entities)
        {
            rel_entity_entity ($dbh, $type0, $type1);
        }

        rel_entity_url ($dbh, $type0);
        rel_entity_work ($dbh, $type0);
    }
}

sub main
{
    my $outputfile = shift;
    my $database = $readwrite->{database};

    my $dbh = DBI->connect("dbi:Pg:dbname=$database",
                           $readwrite->{username}, $readwrite->{password});

    foreach (@ARGV) {
        release_group ($dbh, $_);
    }

    relationships ($dbh);

    print "Writing output to $outputfile ...\n";
    open (DUMP, ">$outputfile");

    print DUMP "-- Generated by ../../script/webservice_test_data.pl\n\n";
    print DUMP "SET client_min_messages TO 'warning';\n\n";
    print DUMP "DELETE FROM release_group_primary_type;\n";
    print DUMP "DELETE FROM release_status;\n\n";

    foreach (@backup)
    {
        print DUMP "$_\n";
    }

    # Patch track_count, as track triggers may have been enabled and messed it up.
    print DUMP "\nUPDATE medium\n" .
        "SET track_count = tc.count\n" .
        "FROM (SELECT count(id),medium FROM track GROUP BY medium) tc\n" .
        "WHERE tc.medium = medium.id;\n\n";

    close (DUMP);

    print "Done!\n";
}

main (shift);
