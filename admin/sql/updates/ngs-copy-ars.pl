#!/usr/bin/perl -w

use strict;
use FindBin;
use lib "$FindBin::Bin/../../../lib";

use DBDefs;
use MusicBrainz;
use MusicBrainz::Server::Validation;
use Sql;
use Getopt::Long;

my $move;
my $remove;
my $result = GetOptions("move", \$move,
                        "remove", \$remove);

if (($remove && scalar(@ARGV) < 2) || (!$remove && scalar(@ARGV) < 3))
{
    print "Usage: ngs-copy-ars.pl [-m | -r] <src_entity_0-src_entity_1> [dest_entity_0-dest_entity_1]\n\n";
    print "Options\n";
    print "    -m     Move the ARs (Copy then remove)\n";
    print "    -r     Remove the ARs (No copy, just remove)\n";
    exit(-1);
}

my $link_type_name = shift; # "cover art link"
my $src_type = shift;       # "release_group-release_group"
my $dest_type;              # "release-release"
$dest_type = shift if (!$remove);

my ($src_entity0, $src_entity1) = split /-/, $src_type;
my ($dest_entity0, $dest_entity1) = split /-/, $dest_type if (!$remove);

# TODO: Make this script ambidextrous
die if ($src_entity0 ne 'release_group');

my $mb = MusicBrainz->new;
$mb->Login(db => "READWRITE");
my $sql = Sql->new($mb->dbh);

$sql->begin;
eval {

    # Find the current link type id
    my $link_type_id = $sql->select_single_value("SELECT id
                                                  FROM link_type
                                                 WHERE name = ?
                                                   AND entitytype0 = ?
                                                   AND entitytype1 = ?", $link_type_name, $src_entity0, $src_entity1);
    die "Cannot find link type $link_type_name!\n" if (!defined $link_type_id);

    if (!$remove)
    {
        print localtime() . " Load release groups into ram\n";
        # Load the release_group => release map into memory
        my %rg_release_map;
        if ($sql->select("SELECT id, release_group FROM release"))
        {
            while (1)
            {
                my $row = $sql->next_row_hash_ref or last;
                $rg_release_map{$row->{release_group}} = [] if (!defined $rg_release_map{$row->{release_group}});
                push @{$rg_release_map{$row->{release_group}}}, $row->{id};
            }
            $sql->finish;
        }

        print localtime() . " create new link_type\n";


        # Create a new link_type and link_type_attribute_type
        my $new_link_type_id = $sql->select_single_value("INSERT INTO link_type (parent, childorder, gid, entitytype0, entitytype1,
                                                             name, description, linkphrase, rlinkphrase,
                                                             shortlinkphrase, priority)
                                          SELECT parent, childorder, generate_uuid_v4(), ?, ?,
                                                 name, description, linkphrase, rlinkphrase,
                                                 shortlinkphrase, priority from link_type
                                           WHERE name = ?
                                             AND entitytype0 = ?
                                             AND entitytype1 = ? RETURNING id", $dest_entity0, $dest_entity1, $link_type_name,
                                                                   $src_entity0, $src_entity1);
        $sql->do("INSERT INTO link_type_attribute_type (link_type, attribute_type, min, max)
                          SELECT ?, attribute_type, min, max
                            FROM link_type_attribute_type
                           WHERE link_type = ?", $new_link_type_id, $link_type_id);

        print localtime() . " copy ARs\n";
        my $total = $sql->select_single_value("SELECT count(*) FROM l_".$src_entity0."_".$src_entity1 . " AS l, link
                                              WHERE link.link_type = ?
                                                AND link.id = l.link", $link_type_id);

        die "There are no ARs to copy/move.\n" if ($total == 0);
        my $count = 0;
        my %links;
        if ($sql->select("SELECT *
                            FROM l_".$src_entity0."_".$src_entity1." AS t, link
                           WHERE t.link = link.id
                             AND link.link_type = ?", $link_type_id))
        {
            my $link_id;
            while (1)
            {
                my $row = $sql->next_row_hash_ref or last;

                # create a unique key that represents an link type
                my $key = sprintf "%d-%d-%d-%d-%d-%d-%d-%d", $new_link_type_id,
                                                             $row->{begindate_year} || 0,
                                                             $row->{begindate_month} || 0,
                                                             $row->{begindate_day} || 0,
                                                             $row->{enddate_year} || 0,
                                                             $row->{enddate_month} || 0,
                                                             $row->{enddate_day} || 0,
                                                             $row->{attributecount} || 0;

                # Now append attribute ids
                my $attrs = $sql->select_single_column_array("SELECT attribute_type
                                                             FROM link_type_attribute_type
                                                            WHERE link_type = ?
                                                         ORDER BY attribute_type", $link_type_id);
                foreach my $attr (@{$attrs})
                {
                    $key .= sprintf "-%d", $attr;
                }

                if (exists $links{$key})
                {
                    $link_id = $links{$key};
                }
                else
                {
                    # Insert the proper link row
                    $link_id = $sql->select_single_value("INSERT INTO link (link_type, begindate_year, begindate_month, begindate_day,
                                                                    enddate_year, enddate_month, enddate_day, attributecount)
                                                             VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                                                          RETURNING id",
                                                        $new_link_type_id,
                                                        $row->{begindate_year},
                                                        $row->{begindate_month},
                                                        $row->{begindate_day},
                                                        $row->{enddate_year},
                                                        $row->{enddate_month},
                                                        $row->{enddate_day},
                                                        $row->{attributecount});
                    $links{$key} = $link_id;
                    $sql->do("INSERT INTO link_attribute (link, attribute_type)
                                 SELECT ?, attribute_type
                                   FROM link_attribute
                                  WHERE link = ?", $link_id, $row->{link});
                }

                my $releases = $rg_release_map{$row->{entity0}};
                foreach my $release (@{$releases})
                {
                    $sql->do("INSERT INTO l_" . $dest_entity0 . "_" . $dest_entity1.
                             " (link, entity0, entity1, editpending) VALUES (?, ?, ?, ?)",
                                               $link_id,
                                               $release,
                                               $row->{entity1},
                                               $row->{editpending});
                }
                $count++;
                printf localtime() . " %d%% complete ($count of $total)\n", ($count * 100 / $total) if ($count % 1000 == 0);
            }
            $sql->finish;
        }
        print localtime() . " Copied $count ARs.\n";
    }

    if ($move || $remove)
    {
        print localtime() . " Removing old ARs and AR type\n";
        # Save a list of rows in the link table will become unused once we delete the rows for a given type
        my $links_to_check = $sql->select_single_column_array("SELECT DISTINCT link
                                                              FROM l_".$src_entity0."_".$src_entity1 . " t, link
                                                             WHERE t.link = link.id
                                                               AND link.link_type = ?", $link_type_id);

        # Delete the rows from the l_<type>_<type> tables
        $sql->do("DELETE FROM l_".$src_entity0."_".$src_entity1 . " t WHERE id IN (
                      SELECT ar.id from l_".$src_entity0."_".$src_entity1 . " ar , link
                       WHERE t.link = link.id
                         AND link_type = ?)", $link_type_id);

        # Check out row in the link table to see if its still used
        # RAK: I'm not 100% certain this check is needed, but in case...
        foreach my $link (@{$links_to_check})
        {
            if (!$sql->select_single_value("SELECT count(*) FROM l_".$src_entity0."_".$src_entity1 . " WHERE link = ?", $link))
            {
                # No references remain. Lets nuke that link and its dependent rows
                $sql->do("DELETE FROM link_attribute WHERE link = ?", $link);
                $sql->do("DELETE FROM link WHERE id = ?", $link);
            }
        }

        # Now remove the link_type and its dependent rows
        $sql->do("DELETE FROM link_type_attribute_type WHERE link_type = ?", $link_type_id);
        $sql->do("DELETE FROM link_type WHERE id = ?", $link_type_id);

        print localtime() . " Done.\n";
    }
#$sql->commit;
    $sql->rollback;
};
if ($@) {
    my $err = $@;
    print localtime() . " Error: $err\n";
    $sql->rollback;
}

