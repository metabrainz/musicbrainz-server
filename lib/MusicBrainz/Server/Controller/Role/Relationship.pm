package MusicBrainz::Server::Controller::Role::Relationship;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

requires 'load';

sub relationships : Chained('load') PathPart('relationships')
{
    my ($self, $c) = @_;
    my $entity = $c->stash->{$self->{entity_name}};
    $c->model('Relationship')->load($entity);
}

after 'load' => sub {
    my ($self, $c) = @_;
    my $entity = $c->stash->{entity};
    if ($c->action->name ne 'relationships') {
        $c->model('Relationship')->load_subset([ 'url' ], $entity);
    }
};

no Moose::Role;
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
