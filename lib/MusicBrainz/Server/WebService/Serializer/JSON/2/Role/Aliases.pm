package MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Aliases;
use Moose::Role;
use List::UtilsBy qw( sort_by );
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( boolean list_of );

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    return $ret unless defined $inc && $inc->aliases;

    my $opts = $stash->store ($entity);

    my @aliases;
    for my $alias (sort_by { $_->name } @{ $opts->{aliases} // [] })
    {
        my $item = { name => $alias->name, "sort-name" => $alias->sort_name };

        $item->{locale} = $alias->locale // JSON::null;
        $item->{primary} = $alias->locale ? boolean ($alias->primary_for_locale) : JSON::null;
        $item->{type} = $alias->type ? $alias->type_name : JSON::null;

        push @aliases, $item;
    }

    $ret->{aliases} = \@aliases;

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

