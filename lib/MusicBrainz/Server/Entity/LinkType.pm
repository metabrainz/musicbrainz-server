package MusicBrainz::Server::Entity::LinkType;
use Moose;

use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation::Relationships qw( l );

extends 'MusicBrainz::Server::Entity';

with 'MusicBrainz::Server::Entity::Role::OptionsTree' => {
    type => 'LinkType',
    sort_criterion => 'name',
};

sub entity_type { 'link_type' }

has 'entity0_type' => (
    is => 'rw',
    isa => 'Str',
);

has 'entity1_type' => (
    is => 'rw',
    isa => 'Str',
);

has 'link_phrase' => (
    is => 'rw',
    isa => 'Str',
);

sub l_link_phrase {
    my $self = shift;
    return l($self->link_phrase);
}

has 'reverse_link_phrase' => (
    is => 'rw',
    isa => 'Str',
);

sub l_reverse_link_phrase {
    my $self = shift;
    return l($self->reverse_link_phrase);
}

has 'long_link_phrase' => (
    is => 'rw',
    isa => 'Str',
);

sub l_long_link_phrase {
    my $self = shift;
    return l($self->long_link_phrase);
}

sub l_description {
    my $self = shift;
    return l($self->description);
}

has 'priority' => (
    is => 'rw',
    isa => 'Int',
);

has 'attributes' => (
    is => 'rw',
    isa => 'ArrayRef[LinkTypeAttribute]',
    traits => [ 'Array' ],
    default => sub { [] },
    lazy => 1,
    handles => {
        clear_attributes => 'clear',
        all_attributes => 'elements',
        add_attribute => 'push'
    }
);

has 'documentation' => (
    is => 'rw'
);

has 'examples' => (
    is => 'rw',
    isa => 'ArrayRef',
    traits => [ 'Array' ],
    handles => {
        all_examples => 'elements',
    }
);

sub published_examples {
    my $self = shift;
    return grep { $_->published } $self->all_examples;
}

has 'is_deprecated' => (
    is => 'rw',
    isa => 'Bool'
);

has 'has_dates' => (
    is => 'rw',
    isa => 'Bool',
);

has 'entity0_cardinality' => (
    is => 'rw',
    isa => 'Int'
);

has 'entity1_cardinality' => (
    is => 'rw',
    isa => 'Int'
);

has 'orderable_direction' => (
    is => 'rw',
    isa => 'Int',
);

has 'root_id' => (
    is => 'rw',
    isa => 'Int',
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;

    my %attrs = map {
        $self->link_entity('link_attribute_type', $_->type_id, $_->type);

        $_->type_id => $_->TO_JSON
    } $self->all_attributes;

    my @children = map { $_->TO_JSON } $self->all_children;

    $json->{attributes} = \%attrs;
    $json->{cardinality0} = $self->entity0_cardinality;
    $json->{cardinality1} = $self->entity1_cardinality;
    $json->{deprecated} = boolean_to_json($self->is_deprecated);
    $json->{documentation} = $self->documentation;
    $json->{examples} = $self->examples;
    $json->{has_dates} = boolean_to_json($self->has_dates);
    $json->{id} = $self->id;
    $json->{root_id} = $self->root_id;
    $json->{link_phrase} = $self->link_phrase;
    $json->{long_link_phrase} = $self->long_link_phrase;
    $json->{orderable_direction} = $self->orderable_direction;
    $json->{reverse_link_phrase} = $self->reverse_link_phrase;
    $json->{type0} = $self->entity0_type;
    $json->{type1} = $self->entity1_type;
    $json->{children} = \@children if @children;

    return $json;
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
