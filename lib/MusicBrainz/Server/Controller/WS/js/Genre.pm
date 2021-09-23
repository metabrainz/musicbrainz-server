package MusicBrainz::Server::Controller::WS::js::Genre;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion';

my $ws_defs = Data::OptList::mkopt([
    'genre' => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(direct limit page timestamp) ]
    }
]);

with 'MusicBrainz::Server::WebService::Validator' => {
    defs => $ws_defs,
    version => 'js',
    default_serialization_type => 'json',
};

sub type { 'genre' }

sub search : Chained('root') PathPart('genre') {
    my ($self, $c) = @_;
    $c->stash->{args}{direct} = 'true';
    $self->dispatch_search($c);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
