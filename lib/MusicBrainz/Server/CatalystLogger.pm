package MusicBrainz::Server::CatalystLogger;
use Moose;

has dispatch => (
    is => 'ro',
    required => 1
);

has abort => (
    is => 'rw',
    default => 0,
);

has message_accumulator => (
    is => 'bare',
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        clear_message_queue => 'clear',
        add_message => 'push',
        messages => 'elements',
        message_queue_size => 'count'
    }
);

sub has_empty_message_queue { !shift->message_queue_size }

{
    foreach my $l (qw/debug info warn error fatal/) {
        my $name = $l;
        $name = 'warning'  if ( $name eq 'warn' );
        $name = 'critical' if ( $name eq 'fatal' );

        __PACKAGE__->meta->add_method(
            "is_${l}" => sub {
                my $self = shift;
                return $self->level_is_valid($name);
            }
        );

        __PACKAGE__->meta->add_method(
            $l => sub {
                my $self = shift;
                my %p = (level => $name, message => "@_");

                $self->add_message(\%p);
            }
        );
    }
}

sub level_is_valid {
    my $self = shift;
    return 0 if ( $self->abort );
    return $self->dispatch->level_is_valid(@_);
}

sub _flush {
    my $self = shift;
    if ( $self->abort || $self->has_empty_message_queue ) {
        $self->abort(undef);
    }
    else {
        foreach my $message ($self->messages) {
            $self->dispatch->log(%$message);
        }
    }

    $self->clear_message_queue;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 201 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
