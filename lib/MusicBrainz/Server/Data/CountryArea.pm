package MusicBrainz::Server::Data::CountryArea;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::Area;

extends 'MusicBrainz::Server::Data::Area';
with 'MusicBrainz::Server::Data::Role::SelectAll' => { order_by => [ 'name ASC' ] };

around '_get_all_from_db' => sub {
    my ($orig, $self, $p) = @_;
    my $query = "SELECT " . $self->_columns .
        " FROM " . $self->_table . " JOIN country_area ca ON ca.area = area.id " .
        " ORDER BY " . (join ", ", @{ $p->order_by });
    $self->query_to_list($query);
};

sub sort_in_forms { 1 }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
