package MusicBrainz::Server::Controller::WS::js::Area;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion';
with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion::PrimaryAlias' => {
    model => 'Area',
};

my $ws_defs = Data::OptList::mkopt([
    'area' => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(direct limit page timestamp) ]
    }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
     version => 'js',
     default_serialization_type => 'json',
};

sub type { 'area' }

sub search : Chained('root') PathPart('area')
{
    my ($self, $c) = @_;
    $self->dispatch_search($c);
}

after _load_entities => sub {
    my ($self, $c, @entities) = @_;
    $c->model('AreaType')->load(@entities);
    $c->model('Area')->load_containment(@entities);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
