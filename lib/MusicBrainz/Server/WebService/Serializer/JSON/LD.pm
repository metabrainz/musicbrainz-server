package MusicBrainz::Server::WebService::Serializer::JSON::LD;
use Moose;

sub serialize {
    my ($self, $entity, $inc, $stash, $toplevel) = @_;
    return $toplevel ? {'@context' => 'http://schema.org'} : {};
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

