package MusicBrainz::Server::Edit::Event::RelatedEntities;
use Moose::Role;
use namespace::autoclean;

requires qw( c event_ids );

around _build_related_entities => sub {
    my ($orig, $self) = @_;

    my @events = values %{
        $self->c->model('Event')->get_by_ids($self->event_ids);
    };

    return {
        event => [ map { $_->id } @events ],
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2024 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
