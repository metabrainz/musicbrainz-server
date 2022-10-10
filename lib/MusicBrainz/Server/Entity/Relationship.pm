package MusicBrainz::Server::Entity::Relationship;

use Moose;
use MusicBrainz::Server::Constants qw(
    :direction
    $SERIES_ORDERING_TYPE_MANUAL
);
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Validation qw( trim_in_place );
use MusicBrainz::Server::Translation qw( comma_list comma_only_list );
use MusicBrainz::Server::Data::Relationship;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json partial_date_to_hash );

use overload '<=>' => \&_cmp, fallback => 1;

extends 'MusicBrainz::Server::Entity';
with  'MusicBrainz::Server::Entity::Role::LastUpdate';
with  'MusicBrainz::Server::Entity::Role::PendingEdits';

sub entity_type { 'relationship' }

has 'link_id' => (
    is => 'ro',
    isa => 'Int',
);

has 'link' => (
    is => 'rw',
    isa => 'Link',
);

has 'direction' => (
    is => 'ro',
    isa => 'Int',
    default => $DIRECTION_FORWARD
);

has 'entity0_id' => (
    is => 'ro',
    isa => 'Int',
);

has 'entity0' => (
    is => 'rw',
    isa => 'Relatable',
);

has 'entity0_credit' => (
    is => 'ro',
    isa => 'Str',
);

has 'entity1_id' => (
    is => 'ro',
    isa => 'Int',
);

has 'entity1' => (
    is => 'rw',
    isa => 'Relatable',
);

has 'entity1_credit' => (
    is => 'ro',
    isa => 'Str',
);

has 'link_order' => (
    is => 'ro',
    isa => 'Int',
);

has '_phrase' => (
    is => 'ro',
    builder => '_build_phrase',
    lazy => 1
);

has '_verbose_phrase' => (
    is => 'ro',
    builder => '_build_verbose_phrase',
    lazy => 1
);

has '_grouping_phrase' => (
    is => 'ro',
    builder => '_build_grouping_phrase',
    lazy => 1,
);

sub entity_is_orderable {
    my ($self, $entity) = @_;

    my $orderable_direction = $self->link->type->orderable_direction;

    return 1 if (
        ($orderable_direction == 1 && $entity == $self->entity1) ||
        ($orderable_direction == 2 && $entity == $self->entity0)
    );

    return 0;
}

sub unorderable_entity {
    my ($self) = @_;
    my $orderable_direction = $self->link->type->orderable_direction;
    if ($orderable_direction == 0) {
        return;
    } elsif ($orderable_direction == 1) {
        return $self->entity0;
    } elsif ($orderable_direction == 2) {
        return $self->entity1
    }
    die 'Entity::Relationship::unorderable_entity: ' .
        'Invalid orderable_direction';
}

sub can_manually_reorder {
    my ($self) = @_;
    my $unorderable_entity = $self->unorderable_entity;
    return 0 unless $unorderable_entity;
    if (
        !$unorderable_entity->isa('MusicBrainz::Server::Entity::Series') ||
        $unorderable_entity->ordering_type_id == $SERIES_ORDERING_TYPE_MANUAL
    ) {
        return 1;
    }
    return 0;
}

has source => (
    is => 'rw',
    isa => 'Relatable',
);

has source_type => (
    is => 'rw',
    isa => 'Str',
);

has source_credit => (
    is => 'rw',
    isa => 'Str',
);

has target => (
    is => 'rw',
    isa => 'Relatable',
);

has target_type => (
    is => 'rw',
    isa => 'Str',
);

has target_credit => (
    is => 'rw',
    isa => 'Str',
);

sub phrase
{
    my ($self) = @_;
    return $self->_phrase->[0];
}

sub extra_phrase_attributes
{
    my ($self) = @_;
    return $self->_phrase->[1];
}

sub verbose_phrase
{
    my ($self) = @_;
    return $self->_verbose_phrase->[0];
}

sub verbose_phrase_with_placeholders {
    my ($self) = @_;

    my $phrase = $self->_verbose_phrase->[0];
    $phrase = "{entity0} $phrase" unless $phrase =~ /\{entity0\}/;
    $phrase = "$phrase {entity1}" unless $phrase =~ /\{entity1\}/;
    return $phrase;
}

sub extra_verbose_phrase_attributes
{
    my ($self) = @_;
    return $self->_verbose_phrase->[1];
}

sub grouping_phrase { shift->_grouping_phrase->[0] }

sub extra_grouping_phrase_attributes { shift->_grouping_phrase->[1] }

sub _build_phrase {
    my ($self) = @_;
    $self->_interpolate(
        $self->direction == $DIRECTION_FORWARD
            ? $self->link->type->l_link_phrase()
            : $self->link->type->l_reverse_link_phrase()
    );
}

sub _build_verbose_phrase {
    my ($self) = @_;
    $self->_interpolate($self->link->type->l_long_link_phrase);
}

=method _build_grouping_phrase

For ordered relationships (such as those in a series), builds a phrase with
attributes removed, so that these relationships can remain grouped together
under the same phrase in our relationships display, even if their attributes
differ.

=cut

sub _build_grouping_phrase {
    my ($self) = @_;
    $self->_interpolate(
        ($self->direction == $DIRECTION_FORWARD
            ? $self->link->type->l_link_phrase
            : $self->link->type->l_reverse_link_phrase),
        ($self->link->type->orderable_direction > 0),
    );
}

sub _interpolate {
    my ($self, $phrase, $for_grouping) = @_;

    my @attrs = $self->link->all_attributes;
    my %attrs;
    foreach my $attr (@attrs) {
        my $name = lc $attr->type->root->name;

        push @{$attrs{$name}}, $attr->html;
    }
    my %extra_attrs = %attrs;

    # In order to keep relationships grouped together under the same link
    # phrase, set %attrs (which contains the replacement values) to (). Now,
    # all attributes will be replaced with the empty string in the phrase,
    # and moved to @extra_attrs so that they can appear in a comma-separated
    # list after the relationship target link. (Normally, @extra_attrs only
    # contains attributes which don't appear in the phrase at all.)
    %attrs = () if $for_grouping;

    my $replace_attrs = sub {
        my ($name, $alt) = @_;

        # placeholders for entity names which are processed elsewhere
        return "{$name}" if $name eq 'entity0' || $name eq 'entity1';

        delete $extra_attrs{$name} unless $for_grouping;
        if (!$alt) {
            return '' unless exists $attrs{$name};
            return comma_list(@{ $attrs{$name} });
        } else {
            my ($alt1, $alt2) = split /\|/, $alt;
            return $alt2 || '' unless exists $attrs{$name};
            my $attr = comma_list(@{ $attrs{$name} });
            $alt1 =~ s/%/$attr/eg;
            return $alt1;
        }
    };
    if (defined $phrase) {
        $phrase =~ s/{(.*?)(?::(.*?))?}/$replace_attrs->(lc $1, $2)/eg;
        trim_in_place($phrase);
    }

    my @extra_attrs = map { @$_ } values %extra_attrs;
    return [ $phrase, comma_only_list(@extra_attrs) ];
}

sub _cmp {
    my ($a, $b) = @_;
    my $a_sortname = $a->target->can('sort_name')
        ? $a->target->sort_name
        : $a->target->name;
    my $b_sortname = $b->target->can('sort_name')
        ? $b->target->sort_name
        : $b->target->name;
    $a->link->type_id           <=> $b->link->type_id ||
    $a->link_order              <=> $b->link_order ||
    $a->link->begin_date        <=> $b->link->begin_date ||
    $a->link->end_date          <=> $b->link->end_date   ||
    $a_sortname cmp $b_sortname;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $link = $self->link;

    if (defined $self->source) {
        $self->link_entity(
            $self->source_type,
            $self->source->id,
            $self->source,
        );
    }

    my $json = {
        attributes      => [map {
            my $type = $_->type;
            $self->link_entity('link_attribute_type', $type->id, $type);
            $self->link_entity('link_attribute_type', $type->root_id, $type->root);
            my $result = { (%{ $_->TO_JSON }, type => { gid => $type->gid }) };
            $result
        } $link->all_attributes],
        editsPending    => boolean_to_json($self->edits_pending),
        ended           => boolean_to_json($link->ended),
        entity0_credit  => $self->entity0_credit,
        entity1_credit  => $self->entity1_credit,
        entity0_id      => $self->entity0_id,
        entity1_id      => $self->entity1_id,
        id              => $self->id ? $self->id + 0 : undef,
        linkOrder       => $self->link_order ? $self->link_order + 0 : 0,
        linkTypeID      => $link->type_id ? $link->type_id + 0 : undef,
        source_id       => defined $self->source ? $self->source->id : undef,
        source_type     => $self->source_type,
        target          => $self->target->TO_JSON,
        target_type     => $self->target_type,
        verbosePhrase   => $link->type_id ? $self->verbose_phrase : '',
    };

    $json->{begin_date} = $link->begin_date->is_empty ? undef : partial_date_to_hash($link->begin_date);
    $json->{end_date} = $link->end_date->is_empty ? undef : partial_date_to_hash($link->end_date);
    $json->{backward} = boolean_to_json($self->direction == $DIRECTION_BACKWARD);

    my $source = $self->source;
    if (defined $source) {
        $self->link_entity($source->entity_type, $source->id, $source);
    }

    if (defined $link->type) {
        $self->link_entity('link_type', $link->type_id, $link->type);

        for my $ltat ($link->type->all_attributes) {
            $self->link_entity('link_attribute_type', $ltat->type_id, $ltat->type);
        }
    }

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
