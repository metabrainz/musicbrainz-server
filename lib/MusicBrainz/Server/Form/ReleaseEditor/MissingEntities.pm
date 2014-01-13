package MusicBrainz::Server::Form::ReleaseEditor::MissingEntities;
use HTML::FormHandler::Moose;

use MusicBrainz::Server::Data::Utils qw( type_to_model );

extends 'MusicBrainz::Server::Form::Step';
has_field 'missing' => ( type => 'Compound' );

has_field "missing.artist" => (
    type => 'Repeatable',
    num_when_empty => 0
);

has_field "missing.artist.name" => (
    type => 'Text',
    required => 1
);

has_field "missing.artist.for" => (
    type => 'Text',
    required => 1
);

has_field "missing.artist.sort_name" => (
    type => 'Text'
);

has_field "missing.artist.comment" => (
    type => 'Text'
);

has_field "missing.artist.entity_id" => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    required => 1
);

sub validate {
    my $self = shift;

    my @new_entities;

    for my $field ($self->field('missing')->field('artist')->fields) {
        next if $field->has_errors;
        next if !defined $field->field('entity_id')->value;

        unless ($field->field('entity_id')->value > 0) {
            $field->field('sort_name')->required(1);
            $field->field('sort_name')->validate_field;
            push @new_entities, $field;
        }
    }

    my %entities = $self->ctx->model('Artist')
        ->find_by_names(map { $_->field('name')->input } @new_entities);

    for my $field (@new_entities)
    {
        if (exists $entities{$field->field('name')->input})
        {
            $field->field('comment')->required(1);
            $field->field('comment')->validate_field;
        }
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010-2011 MetaBrainz Foundation

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
