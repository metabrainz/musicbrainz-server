package MusicBrainz::Server::Database;
use Moose;

has 'username' => (
    isa => 'Str',
    is  => 'rw',
);

has 'password' => (
    isa => 'Maybe[Str]',
    is  => 'rw',
);

has 'database' => (
    isa => 'Str',
    is  => 'rw',
);

has 'host' => (
    isa => 'Str',
    is  => 'rw',
);

has 'port' => (
    isa => 'Int',
    is  => 'rw'
);

sub shell_args
{
    my $self = shift;
    my @args;

    my %vars = (
        '-h' => $self->host,
        '-p' => $self->port,
        '-U' => $self->username
    );

    push @args, map { $_ => $vars{$_} } grep { $vars{$_} } keys %vars;

    push @args, $self->database;

    if (wantarray) {
        return @args;
    }
    else {
        require String::ShellQuote;
        return join ' ', map { String::ShellQuote::shell_quote($_) } @args;
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
