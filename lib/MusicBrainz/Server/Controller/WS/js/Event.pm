package MusicBrainz::Server::Controller::WS::js::Event;
use Moose;
use MooseX::MethodAttributes;
use namespace::autoclean;

extends 'MusicBrainz::Server::ControllerBase::WS::js';

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion';
with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion::PrimaryAlias' => {
    model => 'Event',
};

my $ws_defs = Data::OptList::mkopt([
    'event' => {
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

sub type { 'event' }

sub search : Chained('root') PathPart('event')
{
    my ($self, $c) = @_;
    $self->dispatch_search($c);
}

around _format_output => sub {
    my ($orig, $self, $c, @entities) = @_;
    my %related_entities = $c->model('Event')->find_related_entities(\@entities, 3);

    return map +{
        %$_,
        related_entities => $related_entities{$_->{entity}->id},
    }, $self->$orig($c, @entities);
};

after _load_entities => sub {
    my ($self, $c, @entities) = @_;
    $c->model('EventType')->load(@entities);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
