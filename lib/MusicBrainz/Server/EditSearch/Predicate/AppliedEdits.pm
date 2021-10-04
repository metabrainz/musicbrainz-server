package MusicBrainz::Server::EditSearch::Predicate::AppliedEdits;
use Moose;
use namespace::autoclean;
use feature 'switch';

use MusicBrainz::Server::Constants qw( :edit_status );

no if $] >= 5.018, warnings => 'experimental::smartmatch';

extends 'MusicBrainz::Server::EditSearch::Predicate::ID';

sub combine_with_query {
    my ($self, $query) = @_;

    my $subquery = '(SELECT COUNT(*) FROM edit H WHERE H.editor = edit.editor AND H.status = ?)';

    my $sql;
    given ($self->operator) {
        when ('BETWEEN') {
            $sql = $subquery . ' BETWEEN SYMMETRIC ? AND ?';
        }
        default {
           $sql = join(' ', $subquery, $self->operator, '?');
       }
    }

    $query->add_where([ $sql, [ $STATUS_APPLIED, @{ $self->sql_arguments } ] ]);
}


1;
