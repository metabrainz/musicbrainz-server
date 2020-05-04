package MusicBrainz::Server::Entity::URL::YouTube;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

sub sidebar_name {
    my $self = shift;

    if ($self->url =~ m{^(?:https?:)?//(?:www.)?youtube.com/watch\?v=([a-z0-9_-]+)/?$}i) {
        return 'Play on YouTube';
    }
    elsif ($self->decoded =~ m{^(?:https?:)?//(?:www.)?youtube.com/(?:(?:c|user)/)?([^/#?]+)/?$}i) {
        return $1;
    }
    else {
        return 'YouTube';
    }
};

sub url_is_scheme_independent { 1 }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
