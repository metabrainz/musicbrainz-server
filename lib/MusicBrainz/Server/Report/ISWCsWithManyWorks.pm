package MusicBrainz::Server::Report::ISWCsWithManyWorks;
use Moose;

with 'MusicBrainz::Server::Report::WorkReport',
     'MusicBrainz::Server::Report::FilterForEditor::WorkID';

after _load_extra_work_info => sub {
    my ($self, @works) = @_;

    $self->c->model('Work')->load_writers(@works);
    $self->c->model('Work')->load_recording_artists(@works);
    $self->c->model('WorkType')->load(@works);
    $self->c->model('Language')->load_for_works(@works);
};

sub table { 'iswc_with_many_works' }
sub component_name { 'IswcsWithManyWorks' }

sub query {
    "
        SELECT i.iswc, workcount, w.id AS work_id,
          row_number() OVER (ORDER BY i.iswc)
        FROM iswc i
          JOIN work w ON (w.id = i.work)
          JOIN (
           SELECT iswc, count(*) AS workcount
            FROM iswc
            GROUP BY iswc HAVING count(*) > 1
          ) t ON t.iswc = i.iswc
    ";
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
