package MusicBrainz::Server::Controller::Report;
use Moose;

BEGIN { extends 'Catalyst::Controller'; }

use Data::Page;
use DateTime;
use MusicBrainz::Server::ReportFactory;

sub index : Path('/reports') Args(0)
{
}

sub show : Path Args(1)
{
    my ($self, $c, $name) = @_;

    my $report = MusicBrainz::Server::ReportFactory->create_report($name, $c);
    unless (defined $report) {
        $c->detach('/error_404');
    }

    my $data;
    eval {
        $data = MusicBrainz::Server::ReportFactory->load_report_data($name);
    };
    if ($@) {
        $c->stash( template => 'report/not_available.tt' );
        $c->detach;
    }

    my $page = $c->request->query_params->{page} || 1;
    my $subscribed_artists = $c->request->query_params->{subscribed_artists} || 0;
    $page = 1 if $page < 1;

    my $limit = 50;

    my $pager = Data::Page->new;
    $pager->entries_per_page($limit);
    $pager->total_entries($data->Records);
    $pager->current_page($page);

    $data->Seek(($page - 1) * $limit);
    my @items;
    while ($limit--) {
        my $item = $data->Get or last;
        push @items, $item;
    }

    $report->post_load(\@items);
    if ($subscribed_artists) {
        my $sql = $c->model('MB')->context->sql;
        my $query = "SELECT esa.artist FROM editor_subscribe_artist esa WHERE esa.editor = ?";
        my $subscribed_artist_ids = $sql->select_single_column_array($query, $c->user->id);
        $report->filter_by_artists(\@items, $subscribed_artist_ids);
        $pager->total_entries(scalar @items);
    }

    $c->stash(
        items     => \@items,
        pager     => $pager,
        generated => DateTime->from_epoch( epoch => $data->Time ),
        template  => $report->template,
        subscribed_artists => $subscribed_artists,
    );
}

no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
