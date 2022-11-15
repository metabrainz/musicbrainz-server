package MusicBrainz::Server::Report::FilterForEditor::EventID;
use Moose::Role;

with 'MusicBrainz::Server::Report::FilterForEditor';

sub filter_sql {
    my ($self, $editor_id) = @_;

    return (
        'JOIN l_artist_event ON l_artist_event.entity1 = event_id
         JOIN editor_subscribe_artist esa ON esa.artist = l_artist_event.entity0
         WHERE esa.editor = ?',
        $editor_id
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
