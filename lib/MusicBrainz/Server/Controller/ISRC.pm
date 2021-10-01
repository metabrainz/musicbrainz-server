package MusicBrainz::Server::Controller::ISRC;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Validation qw( is_valid_isrc );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use List::AllUtils qw( sort_by );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'ISRC',
};

sub base : Chained('/') PathPart('isrc') CaptureArgs(0) { }

sub _load : Chained('/') PathPart('isrc') CaptureArgs(1)
{
    my ($self, $c, $isrc) = @_;
    return unless (is_valid_isrc($isrc));

    my @isrcs = $c->model('ISRC')->find_by_isrc($isrc)
      or return;

    $c->stash(
        isrcs => \@isrcs,
        isrc => $isrc,
    );
}

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;

    my $isrcs = $c->stash->{isrcs};
    my @recordings = sort_by { $_->name } $c->model('Recording')->load(@$isrcs);
    $c->model('ArtistCredit')->load(@recordings);
    $c->stash(
        current_view => 'Node',
        component_path => 'isrc/Index',
        component_props => {
            %{$c->stash->{component_props}},
            isrcs => to_json_array($isrcs),
            recordings => to_json_array(\@recordings),
        }
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
