package MusicBrainz::Server::Controller::User::Edits;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

use MusicBrainz::Server::Data::Utils qw( load_everything_for_edits );
use MusicBrainz::Server::Constants ':edit_status';

__PACKAGE__->config(
    paging_limit => 50,
);

sub _edits {
    my ($self, $c, $loader) = @_;

    my $edits = $self->_load_paged($c, $loader);
    $c->stash(
        edits => $edits, # stash early in case an ISE occurs
        template => 'user/edits.tt',
        search => 0,
    );

    load_everything_for_edits($c, $edits);

    return $edits;
}

sub open : Chained('/user/load') PathPart('edits/open') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;
    $self->_edits($c, sub {
        return $c->model('Edit')->find({
            editor => $c->stash->{user}->id,
            status => $STATUS_OPEN
        }, shift, shift);
    });
    $c->stash(
        refine_url_args =>
            { auto_edit_filter => '',
              order => 'desc',
              negation => 0,
              combinator => 'and',
              'conditions.0.field' => 'editor',
              'conditions.0.operator' => '=',
              'conditions.0.name' => $c->stash->{user}->name,
              'conditions.0.args.0' => $c->stash->{user}->id,
              'conditions.1.field' => 'status',
              'conditions.1.operator' => '=',
              'conditions.1.args' => $STATUS_OPEN },
    );
}

sub cancelled : Chained('/user/load') PathPart('edits/cancelled') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;
    $self->_edits($c, sub {
        return $c->model('Edit')->find({
            editor => $c->stash->{user}->id,
            status => $STATUS_DELETED
        }, shift, shift);
    });
    $c->stash(
        refine_url_args =>
            { auto_edit_filter => '',
              order => 'desc',
              negation => 0,
              combinator => 'and',
              'conditions.0.field' => 'editor',
              'conditions.0.operator' => '=',
              'conditions.0.name' => $c->stash->{user}->name,
              'conditions.0.args.0' => $c->stash->{user}->id,
              'conditions.1.field' => 'status',
              'conditions.1.operator' => '=',
              'conditions.1.args' => $STATUS_DELETED },
    );
}

sub accepted : Chained('/user/load') PathPart('edits/accepted') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;
    $self->_edits($c, sub {
        return $c->model('Edit')->find({
            editor => $c->stash->{user}->id,
            status => $STATUS_APPLIED,
            autoedit => 0
        }, shift, shift);
    });
    $c->stash(
        refine_url_args =>
            { auto_edit_filter => 0,
              order => 'desc',
              negation => 0,
              combinator => 'and',
              'conditions.0.field' => 'editor',
              'conditions.0.operator' => '=',
              'conditions.0.name' => $c->stash->{user}->name,
              'conditions.0.args.0' => $c->stash->{user}->id,
              'conditions.1.field' => 'status',
              'conditions.1.operator' => '=',
              'conditions.1.args' => $STATUS_APPLIED },
    );
}

sub failed : Chained('/user/load') PathPart('edits/failed') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;
    $self->_edits($c, sub {
        return $c->model('Edit')->find({
            editor => $c->stash->{user}->id,
            status => [ $STATUS_FAILEDDEP, $STATUS_FAILEDPREREQ,
                        $STATUS_ERROR, $STATUS_NOVOTES ]
        }, shift, shift);
    });
    $c->stash(
        refine_url_args =>
            { auto_edit_filter => '',
              order => 'desc',
              negation => 0,
              combinator => 'and',
              'conditions.0.field' => 'editor',
              'conditions.0.operator' => '=',
              'conditions.0.name' => $c->stash->{user}->name,
              'conditions.0.args.0' => $c->stash->{user}->id,
              'conditions.1.field' => 'status',
              'conditions.1.operator' => '=',
              'conditions.1.args' =>
                  [ $STATUS_FAILEDDEP, $STATUS_FAILEDPREREQ,
                    $STATUS_ERROR, $STATUS_NOVOTES ] },
    );
}

sub rejected : Chained('/user/load') PathPart('edits/rejected') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;
    $self->_edits($c, sub {
        return $c->model('Edit')->find({
            editor => $c->stash->{user}->id,
            status => [ $STATUS_FAILEDVOTE ]
        }, shift, shift);
    });
    $c->stash(
        refine_url_args =>
            { auto_edit_filter => '',
              order => 'desc',
              negation => 0,
              combinator => 'and',
              'conditions.0.field' => 'editor',
              'conditions.0.operator' => '=',
              'conditions.0.name' => $c->stash->{user}->name,
              'conditions.0.args.0' => $c->stash->{user}->id,
              'conditions.1.field' => 'status',
              'conditions.1.operator' => '=',
              'conditions.1.args' => $STATUS_FAILEDVOTE },
    );
}

sub autoedits : Chained('/user/load') PathPart('edits/autoedits') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;
    $self->_edits($c, sub {
        return $c->model('Edit')->find({
            editor => $c->stash->{user}->id,
            autoedit => 1
        }, shift, shift);
    });
    $c->stash(
        refine_url_args =>
            { auto_edit_filter => 1,
              order => 'desc',
              negation => 0,
              combinator => 'and',
              'conditions.0.field' => 'editor',
              'conditions.0.operator' => '=',
              'conditions.0.name' => $c->stash->{user}->name,
              'conditions.0.args.0' => $c->stash->{user}->id },
    );
}

sub applied : Chained('/user/load') PathPart('edits/applied') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;
    $self->_edits($c, sub {
        return $c->model('Edit')->find({
            editor => $c->stash->{user}->id,
            status => $STATUS_APPLIED,
        }, shift, shift);
    });
    $c->stash(
        refine_url_args =>
            { auto_edit_filter => '',
              order => 'desc',
              negation => 0,
              combinator => 'and',
              'conditions.0.field' => 'editor',
              'conditions.0.operator' => '=',
              'conditions.0.name' => $c->stash->{user}->name,
              'conditions.0.args.0' => $c->stash->{user}->id,
              'conditions.1.field' => 'status',
              'conditions.1.operator' => '=',
              'conditions.1.args' => $STATUS_APPLIED },
    );
}

sub all : Chained('/user/load') PathPart('edits') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;
    $self->_edits($c, sub {
        return $c->model('Edit')->find({
            editor => $c->stash->{user}->id
        }, shift, shift);
    });
    $c->stash(
        refine_url_args =>
            { auto_edit_filter => '',
              order => 'desc',
              negation => 0,
              combinator => 'and',
              'conditions.0.field' => 'editor',
              'conditions.0.operator' => '=',
              'conditions.0.name' => $c->stash->{user}->name,
              'conditions.0.args.0' => $c->stash->{user}->id },
    );
}

sub votes : Chained('/user/load') PathPart('votes') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;
    $self->_edits($c, sub {
        return $c->model('Edit')->find_by_voter($c->stash->{user}->id, shift, shift);
    });
    $c->stash( voter => $c->stash->{user} );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
