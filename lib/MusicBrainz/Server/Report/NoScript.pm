package MusicBrainz::Server::Report::NoScript;
use Moose;

with 'MusicBrainz::Server::Report::ReleaseReport',
     'MusicBrainz::Server::Report::FilterForEditor::ReleaseID';

after _load_extra_release_info => sub {
    my ($self, @releases) = @_;

    $self->c->model('Language')->load(@releases);
    $self->c->model('Script')->load(@releases);
};

sub query {
    '
        SELECT
            r.id AS release_id,
            row_number() OVER (ORDER BY r.artist_credit, r.name)
        FROM release r
        WHERE script IS NULL
    ';
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
