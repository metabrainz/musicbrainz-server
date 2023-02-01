package MusicBrainz::Server::Report::FilterForEditor;
use Moose::Role;

requires 'filter_sql';

sub load_filtered {
    my ($self, $c, $editor_id, $limit, $offset) = @_;
    my ($query, @params) = $self->filter_sql($editor_id);
    return $self->_load($c, $query, $limit, $offset, @params);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
