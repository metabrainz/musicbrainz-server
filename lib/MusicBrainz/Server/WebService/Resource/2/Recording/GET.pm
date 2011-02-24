package MusicBrainz::Server::WebService::Resource::2::Recording::GET;
use Moose;
use Data::TreeValidator::Sugar qw( branch leaf );
use namespace::clean;

use MusicBrainz::Server::WebService::Validation qw( gid inc );

with 'MusicBrainz::Server::WebService::Method';

has request_data => (
    is => 'ro',
    default => sub {
        branch {
            gid => gid,
            inc => inc(
                qw( artists isrcs puids ),
                releases => [qw(
                    artist-credits discids media
                )]
            )
        }
    }
);

sub execute {
    my ($self, $input) = @_;
    
}

1;
