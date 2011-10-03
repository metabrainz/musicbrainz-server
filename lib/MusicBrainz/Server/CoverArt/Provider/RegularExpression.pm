package MusicBrainz::Server::CoverArt::Provider::RegularExpression;
use Moose;

use aliased 'MusicBrainz::Server::CoverArt';

extends 'MusicBrainz::Server::CoverArt::Provider';

has 'uri_expression' => (
    isa      => 'Str',
    is       => 'ro',
    required => 1
);

has 'image_uri_template' => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
);

has 'info_uri_template' => (
    isa       => 'Str',
    is        => 'ro',
    predicate => 'has_info_uri_template'
);

has '+link_type_name' => (
    default  => 'cover art link'
);

has 'domain' => (
    isa      => 'Str',
    is       => 'ro',
    required => 1
);

sub handles
{
    my ($self, $cover_art_uri) = @_;
    my $domain = $self->domain;
    return $cover_art_uri =~ /$domain/i;
}

sub lookup_cover_art
{
    my ($self, $cover_art_uri) = @_;
    my $expression = $self->uri_expression;
    my @captures = $cover_art_uri =~ /$expression/i;
    return unless @captures;

    my $cover_art = CoverArt->new(
        image_uri => _rewrite($self->image_uri_template, @captures),
        provider  => $self
    );

    $cover_art->information_uri( _rewrite($self->info_uri_template, @captures) )
        if $self->has_info_uri_template;

    return $cover_art;
}

sub _rewrite {
    my ($template, @captures) = @_;
    # Shove a 0 into the start of the captures array, as all the templates
    # are 1 indexed, not 0 indexed. (I.e., $1 is the first capture)
    unshift @captures, 0;

    # Filter out just defined captures
    my @capture_indexes = grep { defined $captures[$_] } (1..9);

    $template =~ s/\$$_/$captures[$_]/ig for @capture_indexes;
    return $template;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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
