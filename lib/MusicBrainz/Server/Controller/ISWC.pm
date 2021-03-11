package MusicBrainz::Server::Controller::ISWC;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_WORK_REMOVE_ISWC );
use MusicBrainz::Server::Validation qw( format_iswc is_valid_iswc );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use List::UtilsBy qw( sort_by );

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'ISWC',
};

sub base : Chained('/') PathPart('iswc') CaptureArgs(0) { }

sub _load : Chained('/') PathPart('iswc') CaptureArgs(1)
{
    my ($self, $c, $iswc) = @_;
    $iswc = format_iswc($iswc);
    return unless (is_valid_iswc($iswc));

    my @iswcs = $c->model('ISWC')->find_by_iswc($iswc)
        or return;

    $c->stash(
        iswcs => \@iswcs,
        iswc => $iswc,
    );
}

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;

    my $iswcs = $c->stash->{iswcs};
    my @works = sort_by { $_->name } $c->model('Work')->load(@$iswcs);
    $c->model('WorkType')->load(@works);
    $c->model('Work')->load_writers(@works);
    $c->model('Work')->load_recording_artists(@works);
    $c->model('Language')->load_for_works(@works);
    $c->stash(
        current_view => 'Node',
        component_path => 'iswc/Index.js',
        component_props => {
            %{$c->stash->{component_props}},
            iswcs => to_json_array($iswcs),
            works => to_json_array(\@works),
        }
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
