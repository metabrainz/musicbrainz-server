package MusicBrainz::Server::WebService::Resource::2::Recording::GET;
use Moose;
use Data::TreeValidator::Sugar qw( branch leaf );
use namespace::clean;

use MusicBrainz::Server::Validation qw( is_valid_gid );

with 'MusicBrainz::Server::WebService::Method';

has request_data => (
    is => 'ro',
    default => sub {
        branch {
            gid => leaf(
                constraints => [ sub {
                    die 'Invalid MBID'
                        unless is_valid_gid(shift);
                } ],
            )
        }
    }
);

sub execute {
    my ($self, $input) = @_;
    
}

1;
