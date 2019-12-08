package MusicBrainz::Server::Entity::Collection;
use Moose;

use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Filters qw( format_wikitext );

extends 'MusicBrainz::Server::Entity::CoreEntity';

with 'MusicBrainz::Server::Entity::Role::Type' => { model => 'CollectionType' };

sub entity_type { 'collection' }

has 'editor' => (
    is => 'rw',
    isa => 'Editor',
);

has 'editor_id' => (
    is => 'ro',
    isa => 'Int',
);

has 'public' => (
    is => 'rw',
    isa => 'Bool'
);

has 'description' => (
    is => 'rw',
    isa => 'Str'
);

has entity_count => (
    is => 'rw',
    isa => 'Int',
    predicate => 'loaded_entity_count'
);

has subscribed => (
    is => 'rw',
    isa => 'Bool',
    predicate => 'loaded_subscription'
);

has 'collaborators' => (
    isa     => 'ArrayRef[Editor]',
    is      => 'rw',
    traits => [ 'Array' ],
    default => sub { [] },
    handles => {
        all_collaborators => 'elements',
    }
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;

    $json->{editor} = $self->editor ? $self->editor->TO_JSON : undef;
    $json->{public} = boolean_to_json($self->public);
    $json->{description} = $self->description;
    $json->{description_html} = format_wikitext($self->description);
    $json->{collaborators} = [map { $_->TO_JSON } $self->all_collaborators];

    if ($self->loaded_entity_count) {
        $json->{entity_count} = $self->entity_count;
    }

    if ($self->loaded_subscription) {
        $json->{subscribed} = boolean_to_json($self->subscribed);
    }

    return $json;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 Sean Burke

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
