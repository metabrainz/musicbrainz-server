package MusicBrainz::Server::Controller::WS::js::Work;
use Moose;
use MooseX::MethodAttributes;
use namespace::autoclean;

extends 'MusicBrainz::Server::ControllerBase::WS::js';

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion';
with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion::PrimaryAlias' => {
    model => 'Work',
};

my $ws_defs = Data::OptList::mkopt([
    'work' => {
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

sub type { 'work' }

sub search : Chained('root') PathPart('work')
{
    my ($self, $c) = @_;
    $self->dispatch_search($c);
}

after _load_entities => sub {
    my ($self, $c, @entities) = @_;
    $c->model('Language')->load_for_works(@entities);
    $c->model('WorkType')->load(@entities);
};

around _format_output => sub {
    my ($orig, $self, $c, @entities) = @_;
    my %artists = $c->model('Work')->find_artists(\@entities, 3);

    return map +{
        %$_,
        related_artists => $artists{$_->{entity}->id},
    }, $self->$orig($c, @entities);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
