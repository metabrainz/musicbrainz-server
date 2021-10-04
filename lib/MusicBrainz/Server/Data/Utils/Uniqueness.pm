package MusicBrainz::Server::Data::Utils::Uniqueness;
use Moose;

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
            $new_name = "(SELECT $table.name FROM $table
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
            'SELECT ' . $model->_columns .
            ' FROM ' . $model->_table .
            " WHERE (name, comment) IN (SELECT $new_name, $new_comment)".
            ' AND ' . $model->_id_column . ' != ?';

        my ($conflict) = $model->query_to_list($query, [@params, $id]);

        if ($conflict) {
            MusicBrainz::Server::Exceptions::DuplicateViolation->throw({
                conflict => $conflict
            })
        }
    }
}

1;
