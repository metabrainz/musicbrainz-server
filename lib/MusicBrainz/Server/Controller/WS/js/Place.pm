package MusicBrainz::Server::Controller::WS::js::Place;
use Moose;
use MooseX::MethodAttributes;
use namespace::autoclean;

extends 'MusicBrainz::Server::ControllerBase::WS::js';

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion';
with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion::PrimaryAlias' => {
    model => 'Place',
};

my $ws_defs = Data::OptList::mkopt([
    'place' => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(advanced direct limit page timestamp) ],
    },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
     version => 'js',
     default_serialization_type => 'json',
};

sub type { 'place' }

sub search : Chained('root') PathPart('place')
{
    my ($self, $c) = @_;
    $self->dispatch_search($c);
}

after _load_entities => sub{
    my ($self, $c, @entities) = @_;
    $c->model('PlaceType')->load(@entities);
    my @areas = $c->model('Area')->load(@entities);
    $c->model('Area')->load_containment(@areas);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
