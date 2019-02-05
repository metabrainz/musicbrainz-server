package MusicBrainz::Server::Entity::URL::Wikidata;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::MediaWiki';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

=method pretty_name

Attempt to display Wikidata URLs as their Wikidata ID. This will only
happen if the URL can be decoded from utf-8. If not, the entire URL is used.

=cut

sub pretty_name
{
    my $self = shift;
    return $self->name if $self->uses_legacy_encoding;

    return $self->page_name;
}

sub sidebar_name
{
    my $self = shift;

    my $name = $self->pretty_name;
    $name = "Wikidata: $name";

    return $name;
}

sub url_is_scheme_independent { 1 }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
