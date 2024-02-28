package MusicBrainz::Server::Entity::URL::ChangeTip;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

sub sidebar_name {
    my $self = shift;

    if ($self->url =~ m{^https?://(?:www\.)?changetip\.com/tipme/([^/?#]+)$}i) {
        return $1 . '.tip.me';
    }
    else {
        return 'ChangeTip';
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
