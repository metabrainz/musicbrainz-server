package MusicBrainz::Server::Report::EventReport;
use Moose::Role;
use namespace::autoclean;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

with 'MusicBrainz::Server::Report::QueryReport';

around inflate_rows => sub {
    my $orig = shift;
    my $self = shift;

    my $items = $self->$orig(@_);

    my $events = $self->c->model('Event')->get_by_ids(
        map { $_->{event_id} } @$items
    );

    $self->c->model('Event')->load_related_info(values %$events);
    $self->c->model('Event')->load_areas(values %$events);

    return [
        map +{
            %$_,
            event => to_json_object($events->{ $_->{event_id} }),
        }, @$items
    ];
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation
Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
