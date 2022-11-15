package MusicBrainz::Server::Edit::Role::DeleteSubscription;
use Moose::Role;
use namespace::autoclean;

requires '_delete_model', 'subscription_model', 'entity_id';

around accept => sub {
    my ($orig, $self, @args) = @_;

    my @editors =
        map { $_->{editor} }
            @{ $self->subscription_model->delete($self->entity_id) };
    my $entity = $self->c->model($self->_delete_model)->get_by_id($self->entity_id);

    $self->$orig(@args);

    $self->subscription_model->log_deletion_for_editors($self->id, $entity->gid, @editors);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
