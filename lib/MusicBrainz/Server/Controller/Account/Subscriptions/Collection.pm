package MusicBrainz::Server::Controller::Account::Subscriptions::Collection;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

with 'MusicBrainz::Server::Controller::Account::SubscriptionsRole';

__PACKAGE__->config( model => 'Collection' );

before add => sub
{
    my ($self, $c) = @_;

    my $entity_id = $c->request->params->{id};
    my $entity = $c->model($self->{model})->get_by_id($entity_id);

    $c->detach('/error_404') if (!$entity || (!$entity->public && $c->user->id != $entity->editor_id));
};

__PACKAGE__->meta->make_immutable;

1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation
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
