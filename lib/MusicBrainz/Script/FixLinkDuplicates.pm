package MusicBrainz::Script::FixLinkDuplicates;
use Moose;
use DBDefs;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Utils qw( placeholders );
with 'MooseX::Runnable';
with 'MooseX::Getopt';
with 'MusicBrainz::Script::Role::Context';

has dry_run => (
    isa => 'Bool',
    is => 'ro',
    default => 0,
    traits => [ 'Getopt' ],
    cmd_flag => 'dry-run'
);

has limit => (
    isa => 'Int',
    is => 'ro',
    default => 20,
    traits => [ 'Getopt' ],
    cmd_flag => 'limit'
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


sub link_tables {
    my ($self) = @_;
    return map { join('_', 'l', @$_) } $self->c->model('Relationship')->all_pairs;
}

sub sql_do
{
    my ($self, $query, @args) = @_;

    return $self->c->sql->do ($query, @args) unless $self->dry_run;
}

sub remove_one_duplicate
{
    my ($self, $table, $keep_id, $remove_id) = @_;

    # First remove those rows which link = $keep_id and have the same entities.
    my $query = "DELETE FROM $table WHERE id IN (
         SELECT l2.id
           FROM $table l1
           JOIN $table l2
             ON l1.entity0 = l2.entity0
            AND l1.entity1 = l2.entity1
        AND NOT l1.link = l2.link
          WHERE l1.link = ? AND l2.link = ?)";

    $self->sql_do ($query, $keep_id, $remove_id);
    $query = "UPDATE $table SET link = ? WHERE link = ?";
    return $self->sql_do ($query, $keep_id, $remove_id);
}

sub remove_duplicates
{
    my ($self, $keep_id, @remove_ids) = @_;

    printf "%s : Replace links %s with %s\n",
        scalar localtime, join (", ", @remove_ids), $keep_id if $self->verbose;

    my @link_tables = $self->link_tables;

    for my $table (@link_tables)
    {
        for my $remove_id (@remove_ids)
        {
            $self->remove_one_duplicate ($table, $keep_id, $remove_id);
        }
    }

    my $query = "DELETE FROM link_attribute WHERE link IN (" . placeholders (@remove_ids) . ")";
    $self->sql_do ($query, @remove_ids);

    $query = "DELETE FROM link_attribute_credit WHERE link IN (" . placeholders (@remove_ids) . ")";
    $self->sql_do ($query, @remove_ids);

    $query = "DELETE FROM link WHERE id IN (" . placeholders (@remove_ids) . ")";
    $self->sql_do ($query, @remove_ids);
}

sub run {
    my ($self) = @_;

    print localtime() . " : Finding duplicate rows in link table\n";

    # The conditions where 'link' rows are duplicated is when, for the columns of 'link:
    #  * id is different
    #  * link_type is the same
    #  * begin_date_* and end_date_* are the same
    #  * attribute_count is the same
    #  * created is whatever
    #  * ended is the same
    # and where the actual attributes are the same, including credits
    # (not that, at time of this writing, credits are fully implemented)
    # And when we do, we should keep the oldest one (i.e., earliest 'created' date)
    my $query = "
       SELECT array_agg(id ORDER BY created ASC)
           FROM (SELECT link.*,array_agg((attribute_type, credited_as) ORDER BY attribute_type) AS attributes
                 FROM link
                 JOIN link_attribute ON link_attribute.link = link.id
                 LEFT JOIN link_attribute_credit USING (link, attribute_type)
                 GROUP BY link.id) AS link_with_attributes
       GROUP BY link_type, attribute_count, ended, attributes,
                begin_date_year, begin_date_month, begin_date_day,
                end_date_year, end_date_month, end_date_day
         HAVING count(id) > 1";

    my $rows = $self->c->sql->select_single_column_array ($query);

    my ($count, $removed) = (0, 0);

    for my $link (@$rows)
    {
        if ($self->limit > 0 && $count >= $self->limit) {
            print localtime() . " : Removed limit of " . $self->limit . ", stopping until next invocation\n";
            last;
        }
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
            scalar @$rows, ((scalar @$rows)==1 ? "" : "s");
        printf "%s : Processed %d link%s.\n",
            scalar localtime,
            $count, ($count==1 ? "" : "s");
        printf "%s : Successfully removed %d duplicate%s.\n",
            scalar localtime,
            $removed, ($removed==1 ? "" : "s")
                if !$self->dry_run;
    }
}

1;
