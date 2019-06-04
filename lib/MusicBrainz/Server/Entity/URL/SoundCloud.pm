package MusicBrainz::Server::Entity::URL::SoundCloud;

use utf8;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

sub sidebar_name {
    my $self = shift;

    my $name = $self->decoded_local_part;
    # e.g. "/someartist/somesong" -> "someartist/somesong"
    $name =~ s{^/}{};
    # e.g. "someartist/" -> "someartist"
    $name =~ s{/$}{};
    # only show "SoundCloud" for URI parts containing slashes (e.g. songs),
    # since they are too long for the sidebar
    return 'SoundCloud' if $name =~ /\/.+/;

    return $name;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 Johannes Weißl
Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
