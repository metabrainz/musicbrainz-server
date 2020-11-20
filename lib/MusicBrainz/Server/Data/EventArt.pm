package MusicBrainz::Server::Data::EventArt;
use Moose;

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Art',
     'MusicBrainz::Server::Data::Role::PendingEdits' => {
         table => 'event_art_archive.event_art',
     };

sub art_archive_model { shift->c->model('EventArtArchive') }

sub _entity_class { 'MusicBrainz::Server::Entity::EventArt' }

sub find_by_event {
    my ($self, @events) = @_;

    return $self->find_by_entity(\@events);
}

sub find_front_artwork_by_event {
    my ($self, @events) = @_;

    return $self->find_front_artwork_by_entity(\@events);
}

sub find_count_by_event {
    my ($self, $event_id) = @_;

    return $self->find_count_by_entity($event_id);
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
