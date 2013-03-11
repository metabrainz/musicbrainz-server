package MusicBrainz::Server::Data::Utils::Uniqueness;
use Moose;

use MusicBrainz::Server::Data::Utils qw(
    query_to_list
);
use MusicBrainz::Server::Exceptions;

use Sub::Exporter -setup => {
    exports => [qw( assert_uniqueness_conserved )]
};

sub assert_uniqueness_conserved {
    my ($model, $table, $id, $update) = @_;

    # Check if this could violate uniqueness constraints
    if (exists $update->{comment} || exists $update->{name}) {
        my ($new_name, $new_comment, @params);

        if (exists $update->{name}) {
            $new_name = '?::text';
            push @params, $update->{name};
        }
        else {
            $new_name = "(SELECT name.name FROM $table
                          JOIN ${table}_name name ON $table.name = name.id
                          WHERE $table.id = ?)";
            push @params, $id;
        }

        if (exists $update->{comment}) {
            $new_comment = '?::text';
            push @params, $update->{comment};
        }
        else {
            $new_comment = "(SELECT comment FROM $table WHERE id = ?)";
            push @params, $id;
        }

        my $query =
            "SELECT " . $model->_columns .
            ' FROM ' . $model->_table .
            " WHERE (name.name, comment) IN (SELECT $new_name, $new_comment)".
            " AND " . $model->_id_column . " != ?";

        my ($conflict) = query_to_list(
            $model->sql, sub { $model->_new_from_row(shift) }, $query, @params, $id
        );

        if ($conflict) {
            MusicBrainz::Server::Exceptions::DuplicateViolation->throw({
                conflict => $conflict
            })
        }
    }
}

1;
