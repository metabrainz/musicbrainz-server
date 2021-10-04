package MusicBrainz::Server::Report::LabelsDisambiguationSameName;
use Moose;

with 'MusicBrainz::Server::Report::LabelReport',
     'MusicBrainz::Server::Report::FilterForEditor::LabelID';

sub query {
    '
        SELECT
            label.id AS label_id,
            row_number() OVER (ORDER BY label.name COLLATE musicbrainz, label.id)
        FROM label
        WHERE label.name = label.comment
    '
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
