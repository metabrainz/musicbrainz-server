package MusicBrainz::Server::Data::Role::Annotation;
use MooseX::Role::Parameterized;

use MusicBrainz::Server::Data::EntityAnnotation;

parameter 'annotation_table' => (
    required => 1
);

role
{
    my $params = shift;

    requires 'c';

    has 'annotation' => (
        is => 'ro',
        lazy => 1,
        builder => '_build_annotation_data',
    );

    method '_build_annotation_data' => sub
    {
        my $self = shift;
        return MusicBrainz::Server::Data::EntityAnnotation->new(
            c => $self->c,
            table  => $params->annotation_table,
            parent => $self
        );
    };

    before '_delete' => sub {
        my ($self, @ids) = @_;
        $self->annotation->delete(@ids);
    };
};

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

