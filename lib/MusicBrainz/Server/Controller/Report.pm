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
                    return $report->load_filtered($c, $c->user->id, shift, shift);
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
            $report->load($c, shift, shift);
        }
    });

    $_->{text} = format_wikitext($_->{text}) for @$items;

    my $component_name = $report->component_name ? $report->component_name : $name;

    my %props = (
        items         => $items,
        canBeFiltered => boolean_to_json($can_be_filtered),
        filtered      => boolean_to_json($filtered),
        generated     => datetime_to_iso8601($report->generated_at),
        pager => serialize_pager($c->stash->{pager}),
    );

    $c->stash(
        component_path => 'report/'. $component_name,
        component_props => \%props,
        current_view => 'Node',
    );
}

no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
