package MusicBrainz::Server::Controller::WS::2;

use Moose;
use MooseX::MethodAttributes;

extends 'MusicBrainz::Server::ControllerBase::WS::2';

sub default : Path {
    my ($self, $c) = @_;

    $c->detach('not_found');
}

no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
