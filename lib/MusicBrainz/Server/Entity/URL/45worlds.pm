package MusicBrainz::Server::Entity::URL::45worlds;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

override href_url => sub {
    shift->url->as_string =~ s{^http:}{https:}r;
};

sub sidebar_name {
    my $self = shift;

    if ($self->url =~ m{^(?:https?://www.45worlds.com/([a-z0-9]+)/(?:artist|label)/[^/?&#]+)$}i) {
        return '45worlds ' . $1;
    }
    elsif ($self->url =~ m{^(?:https?://www.45worlds.com/classical/(composer|conductor|orchestra|soloist)/[^/?&#]+)$}i) {
        return '45worlds classical (' . $1 . ')';
    }
    else {
        return '45worlds';
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
