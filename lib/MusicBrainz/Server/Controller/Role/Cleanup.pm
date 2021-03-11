package MusicBrainz::Server::Controller::Role::Cleanup;
use Moose::Role;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use namespace::autoclean;

after show => sub {
    my ($self, $c) = @_;
    my $entity = $c->stash->{entity};
    my $eligible_for_cleanup = $c->model( $self->config->{model} )->is_empty($entity->id);
    $c->stash->{component_props}{eligibleForCleanup} =
        boolean_to_json($eligible_for_cleanup);
    $c->stash(
        eligible_for_cleanup => $eligible_for_cleanup
    )
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
