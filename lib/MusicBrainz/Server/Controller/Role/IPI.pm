package MusicBrainz::Server::Controller::Role::IPI;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

requires 'load';

after 'load' => sub {
    my ($self, $c) = @_;
    my $entity_name = $self->{entity_name};
    my $entity = $c->stash->{ $entity_name };
    $c->model( $self->{model} )->ipi->load_for($entity);
};

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
