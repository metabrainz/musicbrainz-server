package MusicBrainz::Server::EditSearch::Predicate::AppliedEdits;
use Moose;
use namespace::autoclean;
use feature 'switch';

use MusicBrainz::Server::Constants qw( :edit_status ); 

extends 'MusicBrainz::Server::EditSearch::Predicate::ID';

sub combine_with_query {
    my ($self, $query) = @_;

    my $having;
    given ($self->operator) {
        when ('BETWEEN') {
            $having = 'count(*) BETWEEN SYMMETRIC ? AND ?';
        }
        default {
            $having = join(' ', 'count(*)', $self->operator, '?');
        }
    }

    my $sql = "EXISTS (
        SELECT 1
        FROM edit edit_inner
        WHERE edit_inner.editor = edit.editor AND edit_inner.status = " . $STATUS_APPLIED .
        "HAVING " . $having .
        ")";
    $query->add_where([ $sql, $self->sql_arguments ]);
}


1;
