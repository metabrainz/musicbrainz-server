package MusicBrainz::Server::Report::FilterForEditor;
use Moose::Role;

requires 'filter_sql';

sub load_filtered {
    my ($self, $c, $editor_id, $limit, $offset) = @_;
    my ($query, @params) = $self->filter_sql($editor_id);
    return $self->_load($c, $query, $limit, $offset, @params);
}

1;
