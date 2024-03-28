package MusicBrainz::Server::Entity::EventArtType;
use Moose;
use MusicBrainz::Server::Translation::Attributes qw( lp );

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::OptionsTree' => {
    type => 'EventArtType',
    sort_criterion => 'id',
};

sub entity_type { 'event_art_type' }

sub l_name {
    my $self = shift;
    return lp($self->name, 'event_art_type');
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
