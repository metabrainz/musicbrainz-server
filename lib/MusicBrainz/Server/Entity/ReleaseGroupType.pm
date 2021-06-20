package MusicBrainz::Server::Entity::ReleaseGroupType;

use Moose;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Translation::Attributes qw( lp );

extends 'MusicBrainz::Server::Entity';

with 'MusicBrainz::Server::Entity::Role::OptionsTree' => {
    type => 'ReleaseGroupType',
};

has 'historic' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

sub entity_type { 'release_group_primary_type' }

sub l_name {
    my $self = shift;
    return lp($self->name, 'release_group_primary_type')
}

around TO_JSON => sub {
    my ($orig, $self) = @_;
    return {
        %{ $self->$orig },
        historic => boolean_to_json($self->historic)
    };
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
