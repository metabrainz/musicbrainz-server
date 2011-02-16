package MusicBrainz::Server::Controller::User::Edits;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

use MusicBrainz::Server::Types ':edit_status';

__PACKAGE__->config(
    paging_limit => 25,
);

sub _edits {
    my ($self, $c, %args) = @_;

    $args{editor} = $c->stash->{user}->id;
    my $edits = $self->_load_paged($c, sub {
        return $c->model('Edit')->find(\%args, shift, shift);
    });

    $c->model('Edit')->load_all(@$edits);
    $c->model('Vote')->load_for_edits(@$edits);
    $c->model('EditNote')->load_for_edits(@$edits);
    $c->model('Editor')->load(map { ($_, @{ $_->votes, $_->edit_notes }) } @$edits);

    $c->stash(
        edits => $edits,
        template => 'edit/search_results.tt',
        search => 0
    );
}

sub open : Chained('/user/load') PathPart('edits/open') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;
    $self->_edits($c, status => $STATUS_OPEN);
}

sub accepted : Chained('/user/load') PathPart('edits/accepted') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;
    $self->_edits($c, status => $STATUS_APPLIED);
}

sub failed : Chained('/user/load') PathPart('edits/failed') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;
    $self->_edits($c, status => [ $STATUS_FAILEDDEP, $STATUS_FAILEDPREREQ,
                                  $STATUS_ERROR, $STATUS_NOVOTES ]);
}

sub rejected : Chained('/user/load') PathPart('edits/rejecte') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;
    $self->_edits($c, status => [ $STATUS_FAILEDVOTE ]);
}

sub autoedits : Chained('/user/load') PathPart('edits/autoedits') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;
    $self->_edits($c, autoedit => 1);
}

sub all : Chained('/user/load') PathPart('edits') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;
    $self->_edits($c);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
