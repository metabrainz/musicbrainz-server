package MusicBrainz::Server::Data::AnnotationRole;

use Moose::Role;
use MusicBrainz::Server::Data::Annotation;

requires 'c';
requires '_annotation_type';

has 'annotation' => (
    is => 'ro',
    default => sub {
        my $self = shift;
        return MusicBrainz::Server::Data::Annotation->new(
            c => $self->c,
            type => $self->_annotation_type
        );
    },
    lazy => 1
);

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

