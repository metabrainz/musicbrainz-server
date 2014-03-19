package MusicBrainz::Server::WebService::Serializer::XML::1::Role::LifeSpan;
use Moose::Role;

sub has_lifespan
{
    my ($self, $entity) = @_;

    my $has_begin_date = !$entity->begin_date->is_empty;
    my $has_end_date = !$entity->end_date->is_empty;

    return $has_begin_date || $has_end_date;
}

sub lifespan
{
    my ($self, $entity) = @_;

    my %attrs;
    $attrs{begin} = $entity->begin_date->format if !$entity->begin_date->is_empty;
    $attrs{end} = $entity->end_date->format if !$entity->end_date->is_empty;

    return $self->gen->life_span (\%attrs);
}

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

