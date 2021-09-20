package MusicBrainz::Server::Entity::URL::BnFCatalogue;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

sub sidebar_name {
    my $self = shift;

    if ($self->url =~ m{^http://catalogue.bnf.fr/ark:/12148/cb([1-4][0-9]{7})[0-9b-z]$}i) {
        return 'FRBNF' . $1;
    }
    else {
        return 'BnF Catalogue';
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
