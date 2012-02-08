package MusicBrainz::WebService::Resource::Label;
use Moose;
use namespace::autoclean;

with 'Sloth::Resource';

use Path::Router;

has '+path' => ( default => 'label/:mbid/' );

has '+_routes' => (
    default => sub {
        my $self = shift;
        return [ do {
            my $router = Path::Router->new;
            $router->add_route(
                '' => (
                    defaults => {
                        resource => $self->name,
                    },
                    target => $self
                )
            );
            $router;
        } ];
    }
);

__PACKAGE__->meta->make_immutable;
1;
