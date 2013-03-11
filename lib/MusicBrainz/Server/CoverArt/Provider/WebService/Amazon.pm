package MusicBrainz::Server::CoverArt::Provider::WebService::Amazon;
use Moose;

use Time::HiRes qw (sleep gettimeofday tv_interval );
use Net::Amazon::AWSSign;
use LWP::UserAgent;
use XML::XPath;
use MusicBrainz::Server::Log qw( log_info );

use aliased 'MusicBrainz::Server::CoverArt::Amazon' => 'CoverArt';

use MusicBrainz::Server::Log qw( log_error );

extends 'MusicBrainz::Server::CoverArt::Provider';

has '+link_type_name' => (
    default => 'amazon asin',
);

has '_aws_signature' => (
    is => 'ro',
    lazy_build => 1,
);

has '_store_map' => (
    is => 'ro',
    default => sub {
        return {
            'amazon.ca' => 'webservices.amazon.ca',
            'amazon.cn' => 'webservices.amazon.cn',
            'amazon.de' => 'ecs.amazonaws.de',
            'amazon.es' => 'webservices.amazon.es',
            'amazon.fr' => 'ecs.amazonaws.fr',
            'amazon.it' => 'webservices.amazon.it',
            'amazon.jp' => 'ecs.amazonaws.jp',
            'amazon.co.jp' => 'ecs.amazonaws.jp',
            'amazon.co.uk' => 'ecs.amazonaws.co.uk',
            'amazon.com' => 'webservices.amazon.com',
        }
    },
    traits => [ 'Hash' ],
    handles => {
        get_store_api => 'get'
    }
);

my $last_request_time;

sub _build__aws_signature
{
    my $public  = DBDefs->AWS_PUBLIC();
    my $private = DBDefs->AWS_PRIVATE();
    return Net::Amazon::AWSSign->new($public, $private);
}

sub handles
{
    # Handle any thing that is an Amazon ASIN url relationship (but only if
    # the server config has AWS keys)
    my $public  = DBDefs->AWS_PUBLIC();
    my $private = DBDefs->AWS_PRIVATE();
    return $public && $private;
}

sub lookup_cover_art
{
    my ($self, $uri) = @_;
    my ($store, $asin) = $uri =~ m{^http://(?:www.)?(.*?)(?:\:[0-9]+)?/.*/([0-9B][0-9A-Z]{9})(?:[^0-9A-Z]|$)}i;
    return unless $asin;

    my $end_point = $self->get_store_api($store);

    unless ($end_point) {
        log_info { "$store does not have a known ECS end point" };
        return;
    }

    my $url = "http://$end_point/onca/xml?" .
                  "Service=AWSECommerceService&" .
                  "Operation=ItemLookup&" .
                  "ItemId=$asin&" .
                  "Version=2011-08-01&" .
                  "ResponseGroup=Images";

    my $cover_art = $self->_lookup_coverart($url) or return;
    $cover_art->asin($asin);
    $cover_art->information_uri($uri);

    return $cover_art;
}

sub _lookup_coverart {
    my ($self, $url) = @_;

    $url .= "&AssociateTag=" . DBDefs->AMAZON_ASSOCIATE_TAG;
    $url = $self->_aws_signature->addRESTSecret($url);

    # Respect Amazon SLA
    if ($last_request_time) {
        my $i = 2 - tv_interval($last_request_time);
        sleep($i) if $i > 0;
    }
    $last_request_time = [ gettimeofday ];

    my $lwp = LWP::UserAgent->new;
    $lwp->env_proxy;
    $lwp->timeout(10);
    my $response = $lwp->get($url) or return;
    if (!$response->is_success) {
        log_error { "Failed to lookup cover art: $_" } $response->decoded_content;
        return;
    }
    my $xp = XML::XPath->new( xml => $response->decoded_content );

    my $image_url = $xp->find(
        '/ItemLookupResponse/Items/Item/ImageSets/ImageSet[@Category="primary"]/LargeImage/URL'
    )->string_value;

    return unless $image_url;

    return CoverArt->new(
        provider        => $self,
        image_uri       => $image_url,
    );
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
