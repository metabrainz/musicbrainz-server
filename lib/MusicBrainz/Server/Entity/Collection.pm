package MusicBrainz::Server::Entity::Collection;
use Moose;

use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
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

    my $editor = $self->editor;
    $json->{editor} = defined $editor ? $editor->TO_JSON : undef;
    $json->{public} = boolean_to_json($self->public);
    $json->{description} = $self->description;
    $json->{description_html} = format_wikitext($self->description);
    $json->{editor_is_limited} = boolean_to_json(defined $editor ? $editor->is_limited : 0);
    $json->{collaborators} = to_json_array($self->collaborators);
    $json->{item_entity_type} = $self->type->item_entity_type if $self->type;

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 Sean Burke

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
