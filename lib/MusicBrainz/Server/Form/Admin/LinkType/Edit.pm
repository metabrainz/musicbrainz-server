package MusicBrainz::Server::Form::Admin::LinkType::Edit;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Admin::LinkType';

has_field 'examples' => (
    type => 'Repeatable',
    num_when_empty => 0
);

has_field 'examples.relationship' => (
    type => 'Compound',
    required => 1
);

has_field 'examples.relationship.id' => (
    type => 'Integer',
    required => 1
);

has_field 'examples.name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1
);

override edit_field_names => sub {
    my $self = shift;
    return ( super(), 'examples' );
};

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
