package MusicBrainz::Server::Controller::WS::js::Recording;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion::WithArtistCredits';
with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion::PrimaryAlias' => {
    model => 'Recording',
};

my $ws_defs = Data::OptList::mkopt([
    "recording" => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(a r direct limit page timestamp) ]
    }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
     version => 'js',
     default_serialization_type => 'json',
};

sub type { 'recording' }

sub search : Chained('root') PathPart('recording')
{
    my ($self, $c) = @_;
    $self->dispatch_search($c);
}

sub _do_direct_search {
    my ($self, $c, $query, $offset, $limit) = @_;

    my $where = {};
    if (my $artist = $c->req->query_params->{a}) {
        $where->{artist} = $artist;
    }

    return $c->model('Search')->search('recording', $query, $limit, $offset, $where);
}

after _load_entities => sub {
    my ($self, $c, @recordings) = @_;
    $c->model('ISRC')->load_for_recordings(@recordings);
};

around _format_output => sub {
    my ($orig, $self, $c, @entities) = @_;
    my %appears_on = $c->model('Recording')->appears_on(\@entities, 3);

    return map +{
        %$_,
        appearsOn => $appears_on{$_->{entity}->id}
    }, $self->$orig($c, @entities);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
