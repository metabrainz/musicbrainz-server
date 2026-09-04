package MusicBrainz::Server::Entity::URL::KKBOX;

use Moose;

use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

sub sidebar_name {
    my $self = shift;

    if (my ($country) = $self->url->path =~ m{^/([a-z]{2})/}i) {
        $country =~ tr/a-z/A-Z/;
        return l('Stream at KKBOX {country}', {
            country => $country,
        });
    } else {
        return l('Stream at KKBOX');
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
