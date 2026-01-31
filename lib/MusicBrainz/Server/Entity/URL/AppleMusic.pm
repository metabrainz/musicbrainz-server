package MusicBrainz::Server::Entity::URL::AppleMusic;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

sub sidebar_name {
    my $self = shift;

    if (my ($country) = $self->url->path =~ m{^/([a-z]{2})/}i) {
        $country =~ tr/a-z/A-Z/;
        return "Apple Music $country";
    } else {
        return 'Apple Music US';
    }
}

sub key {
    # Storefronts on Apple Music and Apple Music Classical share IDs.
    return shift->url =~ s{^https://(?:classical\.)?music\.apple\.com/[a-z]{2}/([a-z-]{3,})/([0-9]+)$}{applemusic:$1:$2}r;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2020 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
