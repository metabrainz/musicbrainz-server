package MusicBrainz::Server::Entity::URL::MediaWiki;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Filters;

sub page_name {
    my $self = shift;
    return undef if $self->uses_legacy_encoding;

    my ($name) = $self->decoded_local_part =~ m{^/wiki/(.*)$}
        or return undef;
    $name =~ tr/_/ /;

    return $name;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation
Copyright (C) 2016 Ulrich Klauer

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
