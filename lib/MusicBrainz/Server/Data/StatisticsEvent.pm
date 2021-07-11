package MusicBrainz::Server::Data::StatisticsEvent;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::StatisticsEvent;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';
with 'MusicBrainz::Server::Data::Role::SelectAll';
with 'MusicBrainz::Server::Data::Role::InsertUpdateDelete';

sub _type { 'statistics_event' }

sub _table
{
    return 'statistics.statistic_event';
}

sub _id_column
{
    return 'statistic_event.date';
}

sub _columns {
    return 'date, title, description, link';
}

sub _column_mapping {
    return {
        date        => 'date',
        title       => 'title',
        description => 'description',
        link        => 'link',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::StatisticsEvent';
}

sub get_by_date {
    my ($self, $date) = @_;

    my @events = $self->_get_by_keys('date', $date);
    return $events[0];
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
