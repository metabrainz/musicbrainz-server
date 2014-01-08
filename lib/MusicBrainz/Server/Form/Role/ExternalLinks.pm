package MusicBrainz::Server::Form::Role::ExternalLinks;
use HTML::FormHandler::Moose::Role;
use MusicBrainz::Server::Translation qw( l N_l );

with 'MusicBrainz::Server::Form::Role::LinkType';

has url_link_types => (
    is => 'ro',
    required => 1,
);

has_field 'url' => (
    type => 'Repeatable',
);

has_field 'url.relationship_id' => (
    type => 'Integer',
    required_when => { removed => 1 },
);

has_field 'url.link_type_id' => (
    type => 'Select',
    required => 1,
    required_message => N_l('Link type is required'),
    localize_meth => sub { my ($self, @message) = @_; return l(@message); },
);

has_field 'url.text' => (
    type => '+MusicBrainz::Server::Form::Field::URL',
    required_when => { removed => 0 },
);

has_field 'url.removed' => (
    type => 'Boolean',
    default => 0
);

sub options_url_link_type_id
{
    my $self = shift;

    my $root = $self->url_link_types;
    my @children = $root->all_children;
    my $entity1_type = $children[0]->entity1_type;
    my $attr = $entity1_type eq 'url' ? 'l_link_phrase' : 'l_reverse_link_phrase';

    return [ $self->_build_options($root, $attr, 'ROOT') ];
}

1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

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
