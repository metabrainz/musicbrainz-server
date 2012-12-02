package MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Annotation;
use Moose::Role;
use List::UtilsBy qw( sort_by );
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( boolean list_of );

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    return $ret unless defined $inc && $inc->annotation;

    my $opts = $stash->store ($entity);


    $ret->{annotation} = $entity->latest_annotation
        ? $entity->latest_annotation->text : JSON::null;

    return $ret;
};

no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

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

