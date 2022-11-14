package MusicBrainz::Server::Entity::URL;
use Moose;

use MooseX::Types::URI qw( Uri );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );

extends 'MusicBrainz::Server::Entity::CentralEntity';

sub entity_type { 'url' }

has 'url' => (
    is => 'ro',
    isa => Uri,
    coerce => 1
);

has 'iri' => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub { shift->url->as_iri },
);

=attribute uses_legacy_encoding

Indicates whether the URL contains bytes that can't be interpreted as UTF-8.

=cut

has 'uses_legacy_encoding' => (
    is => 'ro',
    isa => 'Bool',
    lazy => 1,
    default => sub { shift->iri =~ /%[89A-F]/ },
        # as_iri only leaves bytes with bit 7 set percent-encoded if they
        # are not part of a valid UTF-8 sequence. ASCII characters may
        # still be percent-encoded (e.g. %25, the percent sign itself).
);

=attribute decoded

Returns a fully decoded form of the URL for display, except when the local
part isn't in UTF-8.

NB. This form cannot (reliably) be converted back into a working URL.

=cut

has 'decoded' => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $name = $self->iri;
        return $name if $self->uses_legacy_encoding;
        $name =~ s/%([2-6][0-9A-F]|7[0-9A-E])/chr(hex($1))/eg;
            # still don't decode control characters (00-1F, 7F)
        return $name;
    },
);

has 'decoded_local_part' => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub {
        my $self = shift;
        my ($lp) = $self->decoded =~ m{^(?:[^:]+:)?(?://[^/]*)?(.*)$};
        return $lp // '';
    },
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
most character entities decoded, except when the URL uses a legacy encoding.
In that case, the URL is displayed as it is in the database, complete with
character entities.

=cut

sub pretty_name {
    my $self = shift;

    $self->uses_legacy_encoding ? $self->name : $self->decoded
}

sub name { shift->url->as_string }

sub affiliate_url { shift->url }

sub url_is_scheme_independent { 0 }

sub href_url {
    my $self = shift;
    my $url = $self->affiliate_url;

    if ($self->url_is_scheme_independent) {
        $url = $url->clone;
        $url->scheme('');
    }

    return $url->as_string;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    return {
        %{ $self->$orig },
        $self->can('show_in_external_links') ?
            (show_in_external_links => boolean_to_json($self->show_in_external_links)) : (),
        $self->can('sidebar_name') ?
            (sidebar_name => $self->sidebar_name) : (),
        href_url => $self->href_url,
        pretty_name => $self->pretty_name,
        decoded => $self->decoded,
    };
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2016 Ulrich Klauer

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
