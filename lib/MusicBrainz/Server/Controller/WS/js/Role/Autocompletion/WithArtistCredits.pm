package MusicBrainz::Server::Controller::WS::js::Role::Autocompletion::WithArtistCredits;
use Moose::Role;

with 'MusicBrainz::Server::Controller::WS::js::Role::Autocompletion';

after _load_entities => sub {
    my ($self, $c, @entities) = @_;
    $c->model('ArtistCredit')->load(@entities);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
