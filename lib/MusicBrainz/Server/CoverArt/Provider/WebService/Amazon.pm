package MusicBrainz::Server::CoverArt::Provider::WebService::Amazon;
use Moose;

use Net::Amazon::AWSSign;
use LWP::UserAgent;
use XML::Simple;

use aliased 'MusicBrainz::Server::CoverArt::Amazon' => 'CoverArt';

extends 'MusicBrainz::Server::CoverArt::Provider';

has '+link_type_name' => (
    default => 'amazon asin',
);

has '_aws_signature' => (
    is => 'ro',
    lazy_build => 1,
);

sub _build__aws_signature
{
    my $public  = DBDefs::AWS_PUBLIC();
    my $private = DBDefs::AWS_PRIVATE();
    return Net::Amazon::AWSSign->new($public, $private);
}

sub handles
{
    # Handle any thing that is an Amazon ASIN url relationship (but only if
    # the server config has AWS keys)
    my $public  = DBDefs::AWS_PUBLIC();
    my $private = DBDefs::AWS_PRIVATE();
    return $public && $private;
}

sub lookup_cover_art
{
    my ($self, $uri) = @_;
    my ($store, $asin) = $uri =~ m{^http://(?:www.)?(.*?)(?:\:[0-9]+)?/.*/([0-9B][0-9A-Z]{9})(?:[^0-9A-Z]|$)}i;
    return unless $asin;

    my $url = "http://ecs.amazonaws.com/onca/xml?" .
                  "Service=AWSECommerceService&" .
                  "Operation=ItemLookup&" .
                  "ItemId=$asin&" .
                  "ResponseGroup=Images";

    $url = $self->_aws_signature->addRESTSecret($url);

    my $lwp = LWP::UserAgent->new;
    $lwp->env_proxy;
    my $response = $lwp->get($url) or return;

    my $xml_res = XMLin($response->decoded_content, ForceArray => [ 'ImageSet' ]);

    my $image_url;
    for my $image_set (@{ $xml_res->{Items}->{Item}->{ImageSets}->{ImageSet} }) {
        next unless $image_set->{Category} eq 'primary';
        $image_url = $image_set->{MediumImage}->{URL};
    }

    return unless $image_url;

    my $cover_art = CoverArt->new(
        provider        => $self,
        image_uri       => $image_url,
        information_uri => $uri,
        asin            => $asin
    );

    return $cover_art;
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
