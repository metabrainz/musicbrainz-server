package MusicBrainz::Server::Report::NoLanguage;
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
            r.id AS release_id,
            row_number() OVER (ORDER BY artist_credit.name COLLATE musicbrainz, r.name COLLATE musicbrainz)
        FROM release r
        JOIN artist_credit ON r.artist_credit = artist_credit.id
        WHERE language IS NULL
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
