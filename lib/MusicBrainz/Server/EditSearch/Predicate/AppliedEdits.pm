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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
