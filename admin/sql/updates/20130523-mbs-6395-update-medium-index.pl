#!/usr/bin/env perl

use strict;
use warnings;

use MusicBrainz::Server::Context;
use Sql;
use MusicBrainz::Server::Data::Utils qw( placeholders );

use constant WORK_NO_ERROR => 0;
use constant WORK_DONE => 2;

my $c = MusicBrainz::Server::Context->create_script_context;
my $updated_since = '2013-05-15';

sub get_mediums_to_update
{
    my $c = shift;

    # Any medium where all tracks have a length and that length is < 4800000
    # should have a row in medium_index.

    my $results = $c->sql->select_list_of_hashes (
        "SELECT track.medium AS medium_id,
                (sum(track.length) < 4800000 AND
                 count(track.id) = count(track.length) AND
                 count(track.id) <= 99) AS should_have_index,
                medium_index.medium IS NOT NULL AS has_index
           FROM track
      LEFT JOIN medium_index ON medium_index.medium = track.medium
          WHERE track.medium IN (
                    SELECT distinct(medium)
                      FROM track
                     WHERE track.last_updated >= '$updated_since')
       GROUP BY track.medium, medium_index.medium;");

    my @delete_from_index;
    my @insert_into_index;
    my @update_index;

    for my $medium (@$results)
    {
        if ($medium->{should_have_index})
        {
            if ($medium->{has_index})
            {
                push @update_index, $medium->{medium_id};
            }
            else
            {
                push @insert_into_index, $medium->{medium_id};
            }
        }
        else
        {
            push @delete_from_index, $medium->{medium_id} if $medium->{has_index};
        }
    }

    return {
        delete_from_index => \@delete_from_index,
        insert_into_index => \@insert_into_index,
        update_index => \@update_index
    };
}

sub delete_from_index
{
    my ($c, $medium_ids) = @_;

    $c->sql->do (
        "DELETE FROM medium_index " .
        "WHERE medium IN (" . placeholders(@$medium_ids) . ")",
        @$medium_ids);

    print "Deleted ".scalar @$medium_ids." medium_index rows.\n";
}

sub insert_into_index
{
    my ($c, $medium_ids, $limit) = @_;

    my @ids = grep { $_ } @$medium_ids[0..$limit];

    $c->model('DurationLookup')->update ($_) for @ids;
    print "Inserted ".scalar @ids." medium_index rows.\n";
}

sub update_index
{
    my ($c, $medium_ids, $limit) = @_;

    my $results = $c->sql->select_list_of_hashes (
        "SELECT medium_index.medium AS medium_id
           FROM medium_index
          WHERE medium_index.medium IN (" . placeholders(@$medium_ids) . ")
        AND NOT medium_index.toc = create_cube_from_durations(array(
                    SELECT track.length
                      FROM track
                     WHERE medium = medium_index.medium
                  ORDER BY track.position))
          LIMIT ?;", @$medium_ids, $limit);

    return WORK_DONE unless scalar @$results;

    $c->model('DurationLookup')->update ($_->{medium_id}) for @$results;
    print "Updated ".scalar @$results." medium_index rows.\n";

    return WORK_NO_ERROR;
}

# limit amount of database changes per run.
my $limit = 10;
my $affected = get_mediums_to_update ($c);

my $delete_count = scalar @{ $affected->{delete_from_index} };
my $insert_count = scalar @{ $affected->{insert_into_index} };
my $update_count = scalar @{ $affected->{update_index} };

printf "Need to delete %d medium_index rows\n", $delete_count;
printf "Need to insert %d medium_index rows\n", $insert_count;
printf "Need to update at most %d medium_index rows\n", $update_count;

$c->sql->begin;

# 0 = more work to do.
# 2 = done.
my $exitcode = WORK_NO_ERROR;

if ($delete_count) {
    delete_from_index ($c, $affected->{delete_from_index});
}
elsif ($insert_count) {
    insert_into_index ($c, $affected->{insert_into_index}, $limit);
}
else {
    $exitcode = update_index ($c, $affected->{update_index}, $limit);
}

$c->sql->commit;

exit $exitcode;
