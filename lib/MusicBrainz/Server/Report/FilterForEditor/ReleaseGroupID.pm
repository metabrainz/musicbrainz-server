package MusicBrainz::Server::Report::FilterForEditor::ReleaseGroupID;
use Moose::Role;
use namespace::autoclean;

with 'MusicBrainz::Server::Report::FilterForEditor';

sub filter_sql {
    my ($self, $editor_id) = @_;

    return (
        'JOIN release_group ON release_group.id = release_group_id
         JOIN artist_credit_name ON release_group.artist_credit = artist_credit_name.artist_credit
         JOIN editor_subscribe_artist esa ON esa.artist = artist_credit_name.artist
         WHERE esa.editor = ?',
        $editor_id,
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
