#!/usr/bin/env perl

use warnings;
use strict;

package MusicBrainz::Server::dbmirror;

use English;

# These three subs handle INSERT, UPDATE and DELETE operations respectively.
# Each one accepts a table name and one or two sets of column-value pairs;
# each one then returns an SQL statement and the arguments to go with it.
# The table name will already be quoted and qualified, if required.

sub prepare_insert
{
    my ($table, $valuepairs) = @_;
    %$valuepairs or die;

    my @k = sort keys %$valuepairs;
    my $colnames = join q(, ), map { qq["$_"] } @k;
    my $params = join q(, ), map { '?' } @k;
    my @args = @$valuepairs{@k};

    my $sql = qq[INSERT INTO $table ($colnames) VALUES ($params)];
    return($sql, \@args);
}

sub prepare_update
{
    my ($table, $valuepairs, $keypairs) = @_;
    %$valuepairs or die;
    %$keypairs or die;

    my @k = sort keys %$valuepairs;
    my $setclause = join q(, ), map { qq["$_" = ?] } @k;
    my @setargs = @$valuepairs{@k};

    my ($whereclause, $whereargs) = make_where_clause($keypairs);

    my $sql = qq[UPDATE $table SET $setclause WHERE $whereclause];
    my @args = (@setargs, @$whereargs);
    return($sql, \@args);
}

sub prepare_delete
{
    my ($table, $keypairs) = @_;
    %$keypairs or die;

    my ($whereclause, $whereargs) = make_where_clause($keypairs);

    my $sql = qq[DELETE FROM $table WHERE $whereclause];
    return($sql, $whereargs);
}

# Given a hash of column-value pairs, construct a WHERE clause (using SQL
# placeholders) and a list of arguments to go with it.

sub make_where_clause
{
    my $keypairs = $_[0]; # as returned by unpack_data
    $keypairs or die;
    %$keypairs or die;

    my @conditions;
    my @args;

    for my $column (sort keys %$keypairs)
    {
        if (defined(my $value = $keypairs->{$column}))
        {
                push @conditions, qq["$column" = ?];
                push @args, $value;
        } else {
                push @conditions, qq["$column" IS NULL];
        }
    }

    my $clause = join ' AND ', @conditions;
    return ($clause, \@args);
}

# Given a packed string from "PendingData"."Data", this sub unpacks it into
# a hash of columnname => value.  It returns the hashref, or undef on failure.
# Basically it's the opposite of "packageData" in pending.c

sub unpack_data
{
    my ($packed, $seqid) = @_;
    my %answer;

    while (length($packed))
    {
        # "ColumnName"=
        my ($k) = ($packed =~ /\A"(.*?)"=/)
                or warn(qq(Failed to parse: expected ["ColumnName"=] but found [$packed])), return undef;
        substr($packed, 0, $LAST_PAREN_MATCH[0], '');

        my $v = undef;
        # Optionally, a quoted string
        if ($packed =~ s/\A'//)
        {
                $v = '';

                for (;;)
                {
                        # \\ => \
                        $v .= '\\', next if $packed =~ s/\A\\\\//;

                        # \' => '
                        # '' => '
                        $v .= q('), next if $packed =~ s/\A[\\']'//;

                        # End of string
                        last if $packed =~ s/\A'//;

                        $packed ne ''
                                or warn('Failed to parse: expected string data but found end of string'), return undef;

                        # any other char == itself
                        $v .= substr($packed, 0, 1, '');
                }
        }

        # A space
        $packed =~ s/\A //
                or warn("Failed to parse: expected [ ] but found [$packed]"), return undef;

        #print "Found $k = $v\n";
        $answer{$k} = $v;
    }

    if ($seqid == 111117378 || $seqid == 111117379 || $seqid == 111117380 || $seqid == 111404809) {
        $answer{name} = substr($answer{name}, 0, 1000) . '...';
    }

    return \%answer;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2000 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
