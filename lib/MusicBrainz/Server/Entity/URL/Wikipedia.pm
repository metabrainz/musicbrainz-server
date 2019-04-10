package MusicBrainz::Server::Entity::URL::Wikipedia;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::MediaWiki';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

=method pretty_name

Attempt to display Wikipedia URLs as 'language: Page Name'. This will only
happen if the URL can be decoded from utf-8. If not, the entire URL is used.

=cut

sub pretty_name
{
    my $self = shift;
    return $self->name if $self->uses_legacy_encoding;

    my $name = $self->page_name;

    if (my $language = $self->language) {
        $name = "$language: $name";
    }

    return $name;
}

sub sidebar_name { shift->pretty_name }

sub language
{
    my $self = shift;
    return undef if $self->uses_legacy_encoding;

    if (my ($language) = $self->url->host =~ /(.*)\.wikipedia/) {
        return $language
    } else {
        return undef;
    }
}

=method show_in_external_links

Wikipedia URLs are only show in the sidebar if the URL can be decoded from utf-8

=cut

sub show_in_external_links { !shift->uses_legacy_encoding }

sub url_is_scheme_independent { 1 }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
