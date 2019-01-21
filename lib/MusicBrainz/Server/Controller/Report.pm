package MusicBrainz::Server::Controller::Report;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use DateTime;
use MusicBrainz::Server::Filters qw( format_wikitext );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json datetime_to_iso8601 );
use MusicBrainz::Server::ReportFactory;

sub index : Path('/reports') Args(0)
{
    my ($self, $c) = @_;

    $c->stash(
        current_view => 'Node',
        component_path => 'report/ReportsIndex.js',
    );
}

sub show : Path Args(1)
{
    my ($self, $c, $name) = @_;

    my $report = MusicBrainz::Server::ReportFactory->create_report(
        $name, $c->model('MB')->context
    ) or $c->detach('/error_404');

    if (!$report->generated) {
        $c->stash(
            current_view => 'Node',
            component_path => 'report/ReportNotAvailable.js',
        );
        $c->detach;
    }

    my $filtered = $c->req->query_params->{filter};
    my $can_be_filtered = $report->does('MusicBrainz::Server::Report::FilterForEditor');

    my $items = $self->_load_paged($c, sub {
        if ($filtered) {
            if ($can_be_filtered) {
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
    });

    $_->{text} = format_wikitext($_->{text}) for @$items;

    my %props = (
        items         => $items,
        canBeFiltered => boolean_to_json($can_be_filtered),
        filtered      => boolean_to_json($filtered),
        generated     => datetime_to_iso8601($report->generated_at),
        pager => serialize_pager($c->stash->{pager}),
    );

    $c->stash(
        component_path => 'report/'. $name . '.js',
        component_props => \%props,
        current_view => 'Node',
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
