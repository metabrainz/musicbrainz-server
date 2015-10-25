package MusicBrainz::Server::EditSearch::Predicate::AppliedEdits;
use Moose;
use namespace::autoclean;
use feature 'switch';

use MusicBrainz::Server::Constants qw( :edit_status ); 

extends 'MusicBrainz::Server::EditSearch::Predicate::ID';

sub combine_with_query {
    my ($self, $query) = @_;

    my $subquery = "(SELECT edits_accepted + auto_edits_accepted FROM editor WHERE editor.id = edit.editor)";

    my $sql;
    given ($self->operator) {
        when ('BETWEEN') {
            $sql = $subquery . ' BETWEEN SYMMETRIC ? AND ?';
        }
        default {
           $sql = join(' ', $subquery, $self->operator, '?');
       }
    }

    $query->add_where([ $sql, $self->sql_arguments ]);
}


1;
