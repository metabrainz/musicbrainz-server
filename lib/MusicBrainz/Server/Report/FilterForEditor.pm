package MusicBrainz::Server::Report::FilterForEditor;
use Moose::Role;

requires 'filter_sql';

sub load_filtered {
    my ($self, $editor_id, $limit, $offset) = @_;
    my ($query, @params) = $self->filter_sql($editor_id);
    return $self->_load($query, $offset, $limit, @params);
}

1;
