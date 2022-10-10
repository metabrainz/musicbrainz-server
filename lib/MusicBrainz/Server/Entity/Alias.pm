package MusicBrainz::Server::Entity::Alias;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );

use Moose;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::DatePeriod';
with 'MusicBrainz::Server::Entity::Role::Name';
with 'MusicBrainz::Server::Entity::Role::PendingEdits';
with 'MusicBrainz::Server::Entity::Role::Type' => { model => 'AliasType' };

has 'sort_name' => (
    is => 'rw',
    isa => 'Str'
);

has 'locale' => (
    is  => 'rw',
    isa => 'Str',
);

has 'primary_for_locale' => (
    isa => 'Bool',
    is => 'rw',
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    return {
        %{ $self->$orig },
        locale => $self->locale,
        primary_for_locale => boolean_to_json($self->primary_for_locale),
        sort_name => $self->sort_name,
    };
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation
Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
