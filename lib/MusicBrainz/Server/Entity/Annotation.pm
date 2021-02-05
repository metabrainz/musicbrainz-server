package MusicBrainz::Server::Entity::Annotation;

use Moose;
use MusicBrainz::Server::Data::Utils qw( datetime_to_iso8601 );
use MusicBrainz::Server::Types qw( DateTime );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Filters qw( format_wikitext );

use namespace::autoclean;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Editable';

sub entity_type { 'annotation' }

has 'parent' => (
    does => 'MusicBrainz::Server::Entity::Role::Annotation',
    is => 'rw'
);

has 'editor_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'editor' => (
    is => 'rw',
    isa => 'Editor'
);

has 'text' => (
    is => 'rw',
    isa => 'Maybe[Str]'
);

has 'changelog' => (
    is => 'rw',
    isa => 'Str'
);

has 'creation_date' => (
    is => 'rw',
    isa => DateTime,
    coerce => 1
);

sub summary
{
    my $self = shift;
    return '' unless $self->text;
    my ($summary) = split /(\r?\n){2,}/, $self->text;
    return $summary;
}

sub summary_is_short
{
    my $self = shift;
    return $self->summary && $self->text && $self->summary ne $self->text;
}

sub TO_JSON {
    my ($self) = @_;

    return {
        changelog => $self->changelog,
        creation_date => datetime_to_iso8601($self->creation_date),
        editor => (defined $self->editor ? $self->editor->TO_JSON : undef),
        html => format_wikitext($self->text),
        id => $self->id,
        parent => $self->parent ? $self->parent->TO_JSON : undef,
        text => $self->text,
    };
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
