package MusicBrainz::Server::Entity::URL::VK;

use Moose;

use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

sub sidebar_name {
    my $self = shift;

    if ($self->url =~ m{^(?:https?:)?//(?:[^/]+\.)?vk\.com/(?:artist|audio|music|video)}i) {
        return l('Stream at VK');
    } elsif ($self->decoded =~ m{^https?://(?:www\.)?vk\.com/([^/]+)$}) {
        return $1;
    } else {
        return 'VK';
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
