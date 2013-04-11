package MusicBrainz::Server::Report::ISWCsWithManyWorks;
use Moose;

with 'MusicBrainz::Server::Report::WorkReport',
     'MusicBrainz::Server::Report::FilterForEditor::WorkID';

around inflate_rows => sub {
    my $orig = shift;
    my $self = shift;

    my $rows = $self->$orig(@_);
    $self->c->model('Work')->load_writers(map { $_->{work} } @$rows);
    $self->c->model('Work')->load_recording_artists(map { $_->{work} } @$rows);
    $self->c->model('WorkType')->load(map { $_->{work} } @$rows);
    $self->c->model('Language')->load(map { $_->{work} } @$rows);

    return $rows;
};

sub table { 'iswc_with_many_works' }

sub query {
    "
        SELECT i.iswc, workcount, w.id as work_id,
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

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2013 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
