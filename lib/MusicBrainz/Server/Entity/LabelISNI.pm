package MusicBrainz::Server::Entity::LabelISNI;

use Moose;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::ISNI';

has 'label_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'label' => (
    is => 'rw',
    isa => 'Label'
);

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

