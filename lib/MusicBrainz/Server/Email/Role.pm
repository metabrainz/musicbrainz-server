package MusicBrainz::Server::Email::Role;
use Moose::Role;
use namespace::autoclean;

use MooseX::Types::Moose qw( Str );
use MusicBrainz::Server::Entity::Types;
use String::TT qw( strip );

has 'body' => (
    isa => Str,
    is => 'ro',
    builder => 'text',
    lazy => 1,
    required => 1
);

has 'to' => (
    isa => 'Editor',
    required => 1,
    is => 'ro',
);

has 'subject' => (
    isa => Str,
    required => 1,
    is => 'ro',
);

sub text { '' }

sub header { '' }
sub footer { '' }

around 'text' => sub {
    my $next = shift;
    my ($self, @args) = @_;

    my $email = join("\n\n", map { strip($_) } grep { $_ }
        $self->header,
        $self->$next(@args),
        '-' x 80 . "\n" . $self->footer
    );
};

1;
