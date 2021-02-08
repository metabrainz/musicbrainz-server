package MusicBrainz::Server::Data::Role::Area;
use Moose::Role;

requires '_columns', '_table', '_area_cols';

sub find_by_area
{
    my ($self, $area_id, $limit, $offset) = @_;
    my $area_cols = $self->_area_cols;
    my $name_column = $self->isa('MusicBrainz::Server::Data::Place') ? 'name' : 'name.name';
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE " . join(" OR ", map { $_ . " = ?" } @$area_cols ) . "
                 ORDER BY name COLLATE musicbrainz, id";
    $self->query_to_list_limited($query, [($area_id) x @$area_cols], $limit, $offset);
}

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

