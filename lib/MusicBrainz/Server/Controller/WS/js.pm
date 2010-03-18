package MusicBrainz::Server::Controller::WS::js;

use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller'; }

use MusicBrainz::Server::Constants qw( $DARTIST_ID $DLABEL_ID );
use MusicBrainz::Server::WebService::JSONSerializer;
use MusicBrainz::Server::WebService::Validator;
use Readonly;
use Data::OptList;

# This defines what options are acceptable for WS calls
# rel_status and rg_type are special cases that allow for one release status and one release group
# type per call to be specified.
my $ws_defs = Data::OptList::mkopt([
     artist => {
         method   => 'GET',
         required => [ qw(q) ],
         optional => [ qw(limit timestamp) ]
     },
     label => {
         method   => 'GET',
         required => [ qw(q) ],
         optional => [ qw(limit timestamp) ]
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
     version => 'js',
     default_serialization_type => 'json',
};

Readonly my %serializers => (
    json => 'MusicBrainz::Server::WebService::JSONSerializer',
);

sub bad_req : Private
{
    my ($self, $c) = @_;
    $c->res->status(400);
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->output_error($c->stash->{error}));
}

sub begin : Private
{
}

sub end : Private
{
}

sub root : Chained('/') PathPart("ws/js") CaptureArgs(0)
{
    my ($self, $c) = @_;
    $self->validate($c, \%serializers) or $c->detach('bad_req');
}

sub _autocomplete_entity {
    my ($self, $c, $type, $filter) = @_;

    my $query = $c->stash->{args}->{q};
    my $limit = $c->stash->{args}->{limit} || 10;

    unless ($query) {
        $c->detach('bad_req');
    }

    my @entities = $c->model($type)->autocomplete_name($query, $limit);
    @entities = grep { $_->id != $filter } @entities;

    # FIXME: I think results should be post-processed to sort the entries
    # which match the case of the query above other results.  The sortname
    # should also be taken into account for those entities which have them.
    # -- warp.

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('autocomplete_name', \@entities));
}

sub artist : Chained('root') PathPart('artist') Args(0)
{
    my ($self, $c) = @_;

    $self->_autocomplete_entity($c, 'Artist', $DARTIST_ID);
}

sub label : Chained('root') PathPart('label') Args(0)
{
    my ($self, $c) = @_;

    $self->_autocomplete_entity($c, 'Label', $DLABEL_ID);
}

sub default : Path
{
    my ($self, $c, $resource) = @_;

    $c->stash->{serializer} = $serializers{$self->get_default_serialization_type}->new();
    $c->stash->{error} = "Invalid resource: $resource.";
    $c->detach('bad_req');
}

no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
