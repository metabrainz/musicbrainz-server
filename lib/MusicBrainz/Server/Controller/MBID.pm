package MusicBrainz::Server::Controller::MBID;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( entities_with );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Validation qw( is_guid );

BEGIN { extends 'MusicBrainz::Server::Controller'; }

sub base : Path('/mbid') CaptureArgs(0) { }

sub show : Path('/mbid') CaptureArgs(1) {
    my ($self, $c, $gid) = @_;

    my $is_guid = is_guid($gid);

    if ($is_guid) {
        for my $model (entities_with('mbid', take => 'model')) {
            next unless $c->model($model)->get_by_gid($gid);
            $c->response->redirect(
                $c->uri_for_action(
                    $c->controller($model)->action_for('show'),
                    [ $gid ]));
            $c->detach;
        }
    }

    $c->stash(
        component_path => 'mbid/NotFound',
        component_props => {isGuid => boolean_to_json($is_guid), mbid => $gid},
        current_view => 'Node',
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
