package MusicBrainz::Server::Controller::User::Edits;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

use MusicBrainz::Server::Types '$STATUS_OPEN';

__PACKAGE__->config(
    paging_limit => 25,
);

sub open : Chained('/user/base') PathPart('open-edits') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;

    my $edits = $self->_load_paged($c, sub {
        return $c->model('Edit')->find({ editor => $c->stash->{user}->id, status => $STATUS_OPEN },
                                       shift, shift);
    });

    $c->stash( edits => $edits );
}

sub all : Chained('/user/base') PathPart('all-edits') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;

    my $edits = $self->_load_paged($c, sub {
        return $c->model('Edit')->find({ editor => $c->stash->{user}->id },
                                       shift, shift);
    });

    $c->stash( edits => $edits );
}

# Load related entities for all edits
for my $action (qw( open all )) {
    after $action => sub {
        my ($self, $c) = @_;
        my $edits = $c->stash->{edits};

        $c->model('Edit')->load_all(@$edits);
        $c->model('Editor')->load(@$edits);
    };
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
