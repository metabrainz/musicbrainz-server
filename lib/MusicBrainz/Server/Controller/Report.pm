package MusicBrainz::Server::Controller::Report;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use DateTime;
use MusicBrainz::Server::ReportFactory;

sub index : Path('/reports') Args(0)
{
}

sub show : Path Args(1)
{
    my ($self, $c, $name) = @_;

    my $report = MusicBrainz::Server::ReportFactory->create_report(
        $name, $c->model('MB')->context
    ) or $c->detach('/error_404');

    if (!$report->generated) {
        $c->stash( template => 'report/not_available.tt' );
        $c->detach;
    }

    my $filtered = $c->req->query_params->{filter};
    $c->stash(
        items => $self->_load_paged($c, sub {
            if ($filtered) {
                if ($report->does('MusicBrainz::Server::Report::FilterForEditor')) {
                    if ($c->user_exists) {
                        return $report->load_filtered($c->user->id, shift, shift);
                    }
                    else {
                        $c->forward('/user/login')
                    }
                }
                else {
                    die 'This report does not support filtering';
                }
            }
            else {
                $report->load(shift, shift);
            }
        }),
        filtered => $filtered,
        report => $report,
        generated => $report->generated_at,
        template => $report->template,
    );
}

no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2012 MetaBrainz Foundation

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
