package MusicBrainz::Server::Entity::URL;
use Moose;

use Encode 'decode';
use MooseX::Types::URI qw( Uri );
use MusicBrainz::Server::Filters;
use URI::Escape;
use Try::Tiny;

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Linkable';

has 'url' => (
    is => 'rw',
    isa => Uri,
    coerce => 1
);

=attribute utf8_decoded

Returns the URL, with entities unescaped and the string decoded from utf-8 into
a Perl string. If the decoding fails, then the URL is probably not in utf-8
encoding, and `undef` is returned.

=cut

has utf8_decoded => (
    is => 'ro',
    default => sub {
        my $self = shift;
        try {
            decode('utf-8', uri_unescape($self->url->as_string),
                   Encode::FB_CROAK);
        }
        catch {
            return undef;
        }
    },
    lazy => 1
);

# Some things that don't know what they are constructing may try and use
# `name' - but this really means the `url' attribute
sub BUILDARGS {
    my $self = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;
    if (my $name = delete $args{name}) {
        $args{url} = $name;
    }

    return \%args;
}

=method pretty_name

Return a human readable display of this URL. This is usually the URL with
character entities unescaped, however we only do this if the encoding is UTF-8.
If decoding fails, the URL is displayed as it is in the database, complete with
character entities.

=cut

sub pretty_name {
    my $self = shift;
    return $self->utf8_decoded // $self->url->as_string;
}

sub name { shift->url->as_string }

sub affiliate_url {
	my ($self, $url) = @_;

	return $url;
}

sub url_is_scheme_independent { 0 }

sub scheme_independent_url {
	my ($self, $url) = @_;

	if ($self->url_is_scheme_independent()) {
		$url->scheme("");
	}

	return $url;
}

sub href_url {
	my $self = shift;

	return $self->scheme_independent_url($self->affiliate_url($self->url))
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
