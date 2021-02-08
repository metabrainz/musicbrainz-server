package MusicBrainz::Server::Report::ReleasesWithUnlikelyLanguageScript;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

around inflate_rows => sub {
    my $orig = shift;
    my $self = shift;

    my $rows = $self->$orig(@_);
    $self->c->model('Language')->load(map { $_->{release} } @$rows);
    $self->c->model('Script')->load(map { $_->{release} } @$rows);

    return $rows;
};

sub query {
    "
        SELECT
            DISTINCT r.id AS release_id,
            row_number() OVER (ORDER BY ac.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
        FROM
            release r
            JOIN artist_credit ac ON r.artist_credit = ac.id
            JOIN script ON r.script = script.id
            JOIN language ON r.language = language.id
        WHERE (
            script.iso_code NOT IN ('Kana', 'Latn', 'Qaaa') AND 
            language.iso_code_3 IN (
              'eng', 'spa', 'deu', 'fra', 'por', 'ita', 'swe', 'nor', 'fin',
              'est', 'lav', 'lit', 'pol', 'nld', 'cat', 'hun', 'ces', 'slk',
              'dan', 'ron', 'slv', 'hrv'
            )
        ) OR (
            language.iso_code_3 = 'jpn' AND 
            script.iso_code NOT IN ('Hira', 'Hrkt', 'Kana', 'Jpan', 'Latn', 'Qaaa') 
        ) 
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

