package MusicBrainz::Server::Email::Role;
use Moose::Role;
use namespace::autoclean;

use DBDefs;
use Encode qw( encode );
use MooseX::Types::Moose qw( Str );
use MusicBrainz::Server::Constants qw( $EMAIL_NOREPLY_ADDRESS );
use MusicBrainz::Server::Email;
use MusicBrainz::Server::Entity::Types;
use String::TT qw( strip );

requires 'to', 'subject';

has 'body' => (
    isa => Str,
    is => 'ro',
    builder => 'text',
    lazy => 1,
    required => 1
);

has 'from' => (
    isa => Str,
    is => 'ro',
    required => 1,
    default => $EMAIL_NOREPLY_ADDRESS
);

has 'server' => (
    isa => Str,
    is => 'ro',
    default => sub { $MusicBrainz::Server::Email::url_prefix },
);

sub text { '' }

sub header { '' }
sub footer { '' }
sub extra_headers { () }

around 'text' => sub {
    my $next = shift;
    my ($self, @args) = @_;

    my $footer = $self->footer;
    return join("\n\n", map { strip($_) } grep { $_ }
        $self->header,
        $self->$next(@args),
        $footer ? '-' x 80 . "\n" . $footer : ''
    );
};

sub create_email {
    my $self = shift;
    my @headers = (
        To => $self->to,
        From => $self->from,
        Subject => $self->subject,
    );
    push @headers, $self->extra_headers;
    return Email::MIME->create(
        header => \@headers,
        body => encode('utf-8', $self->body),
        attributes => {
            content_type => 'text/plain',
            charset      => 'UTF-8',
            encoding     => 'quoted-printable',
        }
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
