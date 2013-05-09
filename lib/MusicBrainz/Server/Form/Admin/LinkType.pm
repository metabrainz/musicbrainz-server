package MusicBrainz::Server::Form::Admin::LinkType;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names {
    qw( parent_id child_order name link_phrase reverse_link_phrase
        long_link_phrase description priority attributes documentation
  ) }

has '+name' => ( default => 'linktype' );

has_field 'parent_id' => (
    type => 'Select',
);

has_field 'child_order' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    required => 1,
);

has_field 'name' => (
    type      => 'Text',
    required  => 1,
    maxlength => 255
);

has_field 'link_phrase' => (
    type      => 'Text',
    required  => 1,
    maxlength => 255
);

has_field 'reverse_link_phrase' => (
    type      => 'Text',
    required  => 1,
    maxlength => 255
);

has_field 'long_link_phrase' => (
    type      => 'Text',
    required  => 1,
    maxlength => 255
);

has_field 'description' => (
    type => 'Text',
    not_nullable => 1
);

has_field 'priority' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    required => 1,
);

has_field 'attributes' => (
    type => 'Repeatable',
    num_when_empty => 0
);

has_field 'attributes.type' => (
    type => 'PrimaryKey'
);

has_field 'attributes.active' => (
    type => 'Boolean'
);

has_field 'attributes.min' => (
    type => '+MusicBrainz::Server::Form::Field::Integer'
);

has_field 'attributes.max' => (
    type => '+MusicBrainz::Server::Form::Field::Integer'
);

has_field 'documentation' => (
    type => 'TextArea',
    not_nullable => 1
);

has root => (
    is => 'ro',
    required => 1
);

sub _build_parent_id_options
{
    my ($self, $root, $indent) = @_;

    my @options;
    if ($root->id) {
        push @options, $root->id, $indent . $root->name if $root->id;
        $indent .= '&#xa0;&#xa0;&#xa0;';
    }
    foreach my $child ($root->all_children) {
        push @options, $self->_build_parent_id_options($child, $indent);
    }
    return @options;
}

sub options_parent_id
{
    my ($self) = @_;
    return [ $self->_build_parent_id_options($self->root, '') ];
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
