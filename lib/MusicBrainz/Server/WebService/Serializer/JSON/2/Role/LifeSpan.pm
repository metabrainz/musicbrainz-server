package MusicBrainz::Server::WebService::Serializer::JSON::2::Role::LifeSpan;
use Moose::Role;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( date_period );

sub has_lifespan
{
    my ($self, $entity) = @_;

    my $has_begin_date = !$entity->begin_date->is_empty;
    my $has_end_date = !$entity->end_date->is_empty;

    return $has_begin_date || $has_end_date;
}

around serialize => sub {
    my ($orig, $self, $entity, $inc, $opts, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $opts, $toplevel);

    return $ret unless $toplevel;

    $ret->{"life-span"} = date_period ($entity);

    return $ret;
};

no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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

