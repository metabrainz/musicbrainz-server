package MusicBrainz::Script::FixLinkDuplicates;
use Moose;

use DBDefs;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Utils qw( placeholders );

with 'MooseX::Runnable';
with 'MooseX::Getopt';
with 'MusicBrainz::Script::Role::Context';

my @link_tables = qw(
    l_artist_artist
    l_artist_label
    l_artist_recording
    l_artist_release
    l_artist_release_group
    l_artist_url
    l_artist_work
    l_label_label
    l_label_recording
    l_label_release
    l_label_release_group
    l_label_url
    l_label_work
    l_recording_recording
    l_recording_release
    l_recording_release_group
    l_recording_url
    l_recording_work
    l_release_group_release_group
    l_release_group_url
    l_release_group_work
    l_release_release
    l_release_release_group
    l_release_url
    l_release_work
    l_url_url
    l_url_work
    l_work_work );

has dry_run => (
    isa => 'Bool',
    is => 'ro',
    default => 0,
    traits => [ 'Getopt' ],
    cmd_flag => 'dry-run'
);

has summary => (
    isa => 'Bool',
    is => 'ro',
    default => 1,
);

has verbose => (
    isa => 'Bool',
    is => 'ro',
    default => 0,
);

sub sql_do
{
    my ($self, $query, @args) = @_;

    $self->c->sql->do ($query, @args) unless $self->dry_run;
}

sub remove_one_duplicate
{
    my ($self, $table, $keep_id, $remove_id) = @_;

    my $query = "DELETE FROM $table WHERE id IN (
         SELECT l2.id
           FROM $table l1
           JOIN $table l2
             ON l1.entity0 = l2.entity0
            AND l1.entity1 = l2.entity1
        AND NOT l1.link = l2.link
          WHERE l1.link = ? AND l2.link = ?)";

    # First remove those rows which link = $keep_id and have the same entities.
    $self->sql_do ($query, $keep_id, $remove_id);

    $query = "UPDATE $table SET link = ? WHERE link = ?";
    $self->sql_do ($query, $keep_id, $remove_id);
}

sub remove_duplicates
{
    my ($self, $keep_id, @remove_ids) = @_;

    printf "%s : Replace links %s with %s\n",
        scalar localtime, join (", ", @remove_ids), $keep_id if $self->verbose;

    for my $table (@link_tables)
    {
        for my $remove_id (@remove_ids)
        {
            $self->remove_one_duplicate ($table, $keep_id, $remove_id);
        }
    }

    my $query = "DELETE FROM link_attribute WHERE link IN (" . placeholders (@remove_ids) . ")";
    $self->sql_do ($query, @remove_ids);

    $query = "DELETE FROM link WHERE id IN (" . placeholders (@remove_ids) . ")";
    $self->sql_do ($query, @remove_ids);
}

sub run {
    my ($self) = @_;

    print localtime() . " : Finding duplicate rows in link table\n";

    my $rows = $self->c->sql->select_single_column_array (
        "SELECT array_agg(id)
           FROM (SELECT link.*,array_agg(attribute_type ORDER BY attribute_type) AS attributes
                 FROM link
                 JOIN link_attribute ON link_attribute.link = link.id
                 GROUP BY link.id) AS link_with_attributes
       GROUP BY link_type, attribute_count, ended, attributes,
                begin_date_year, begin_date_month, begin_date_day,
                end_date_year, end_date_month, end_date_day
         HAVING count(id) > 1;");

    my ($count, $removed) = (0, 0);

    for my $link (@$rows)
    {
        my $keep = shift $link;

        Sql::run_in_transaction(sub {
            $self->remove_duplicates ($keep, @$link);
        }, $self->c->sql);

        $removed += scalar @$link;
        $count++;
    }

    if ($self->summary) {
        printf "%s : Found %d duplicated link%s.\n",
            scalar localtime,
            $count, ($count==1 ? "" : "s");
        printf "%s : Successfully removed %d duplicate%s.\n",
            scalar localtime,
            $removed, ($removed==1 ? "" : "s")
                if !$self->dry_run;
    }
}

1;
