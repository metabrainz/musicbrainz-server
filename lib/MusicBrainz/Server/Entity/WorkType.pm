package MusicBrainz::Server::Entity::WorkType;

use Moose;
use MusicBrainz::Server::Translation::Attributes qw( lp );

extends 'MusicBrainz::Server::Entity';

with 'MusicBrainz::Server::Entity::Role::OptionsTree' => {
    type => 'WorkType',
};

sub entity_type { 'work_type' }

sub l_name {
    my $self = shift;
    return lp($self->name, 'work_type')
}

sub l_description {
    my $self = shift;
    return lp($self->description, 'work_type');
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
