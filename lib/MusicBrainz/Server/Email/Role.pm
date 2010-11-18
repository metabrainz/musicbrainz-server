package MusicBrainz::Server::Email::Role;
use Moose::Role;
use namespace::autoclean;

use MooseX::Types::Moose qw( Str );
use MusicBrainz::Server::Email;
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
    isa => Str,
    required => 1,
    is => 'ro',
);

has 'subject' => (
    isa => Str,
    required => 1,
    is => 'ro',
);

has 'from' => (
    isa => Str,
    is => 'ro',
    required => 1,
    default => $MusicBrainz::Server::Email::NOREPLY_ADDRESS
);

sub text { '' }

sub header { '' }
sub footer { '' }
sub extra_headers { () }

around 'text' => sub {
    my $next = shift;
    my ($self, @args) = @_;

    my $email = join("\n\n", map { strip($_) } grep { $_ }
        $self->header,
        $self->$next(@args),
        '-' x 80 . "\n" . $self->footer
    );
};

sub create_email {
    my $self = shift;
    return Email::MIME->create(
        header => [
            To => $self->to,
            From => $self->from,
            Subject => $self->subject
        ],
        body => $self->body,
        attributes => {
            content_type => "text/plain",
            charset      => "UTF-8",
            encoding     => "quoted-printable",
        }
    );
}

1;
