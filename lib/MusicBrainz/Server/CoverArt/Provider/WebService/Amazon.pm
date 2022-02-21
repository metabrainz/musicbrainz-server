package MusicBrainz::Server::CoverArt::Provider::WebService::Amazon;
use Moose;

use Net::Amazon::AWSSign;
use XML::XPath;

use aliased 'MusicBrainz::Server::CoverArt::Amazon' => 'CoverArt';

with 'MusicBrainz::Server::CoverArt::Provider';

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

sub parse_asin {
    my $uri = shift;
    my ($store, $asin) = $uri =~ m{^https?://(?:www.)?(.*?)(?:\:[0-9]+)?/.*/([0-9B][0-9A-Z]{9})(?:[^0-9A-Z]|$)}i;
    return ($store, $asin);
}

sub lookup_cover_art
{
    my ($self, $uri) = @_;

    # Amazon cover art support is pending removal
    return;
}

sub fallback_meta {
    my ($self, $uri) = @_;
    my (undef, $asin) = parse_asin($uri);
    return unless $asin;
    return { amazon_asin => $asin };
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
