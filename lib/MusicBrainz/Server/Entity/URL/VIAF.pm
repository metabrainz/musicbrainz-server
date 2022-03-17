package MusicBrainz::Server::Entity::URL::VIAF;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

override href_url => sub {
    # Turn the official permalink into what VIAF currently redirects to.
    shift->url->as_string =~
        s{^http://viaf\.org/viaf/([0-9]+)$}{https://viaf.org/viaf/$1/}r;
};

sub pretty_name
{
    my $self = shift;
    return 'VIAF' if $self->uses_legacy_encoding;

    my $name = $self->decoded_local_part;
    $name =~ s{^/viaf/}{};

    return $name;
}

sub sidebar_name
{
    my $self = shift;

    my $name = $self->pretty_name;
    $name = "VIAF: $name";

    return $name;
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
