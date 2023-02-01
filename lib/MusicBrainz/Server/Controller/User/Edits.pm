package MusicBrainz::Server::Controller::User::Edits;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

use MusicBrainz::Server::Data::Utils qw( load_everything_for_edits );
use MusicBrainz::Server::Constants qw( :edit_status );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Entity::Util::JSON qw(
    to_json_array
    to_json_object
);

__PACKAGE__->config(
    paging_limit => 50,
);

sub _edits {
    my ($self, $c, $loader) = @_;

    my $edits = $self->_load_paged($c, $loader);
    $c->stash( edits => $edits ); # stash early in case an ISE occurs

    load_everything_for_edits($c, $edits);

    return $edits;
}

sub open : Chained('/user/load') PathPart('edits/open') RequireAuth HiddenOnMirrors {
    my ($self, $c) = @_;
    my $edits = $self->_edits($c, sub {
        return $c->model('Edit')->find({
            editor => $c->stash->{user}->id,
            status => $STATUS_OPEN
        }, shift, shift);
    });

    my $user = to_json_object($c->stash->{user});
    my $refine_url_args = {
        form_only => 'yes',
        auto_edit_filter => '',
        order => 'desc',
        negation => 0,
        combinator => 'and',
        'conditions.0.field' => 'editor',
        'conditions.0.operator' => '=',
        'conditions.0.name' => $c->stash->{user}->name,
        'conditions.0.args.0' => $c->stash->{user}->id,
        'conditions.1.field' => 'status',
        'conditions.1.operator' => '=',
        'conditions.1.args' => $STATUS_OPEN,
    };

    $c->stash(
        current_view => 'Node',
        component_path => 'user/UserEdits',
        component_props => {
            editCountLimit => $c->stash->{edit_count_limit},
            edits => to_json_array($edits),
            pager => serialize_pager($c->stash->{pager}),
            refineUrlArgs => $refine_url_args,
            user => $user,
        },
    );
}

sub cancelled : Chained('/user/load') PathPart('edits/cancelled') RequireAuth HiddenOnMirrors {
    my ($self, $c) = @_;
    my $edits = $self->_edits($c, sub {
        return $c->model('Edit')->find({
            editor => $c->stash->{user}->id,
            status => $STATUS_DELETED
        }, shift, shift);
    });

    my $user = to_json_object($c->stash->{user});
    my $refine_url_args = {
        form_only => 'yes',
        auto_edit_filter => '',
        order => 'desc',
        negation => 0,
        combinator => 'and',
        'conditions.0.field' => 'editor',
        'conditions.0.operator' => '=',
        'conditions.0.name' => $c->stash->{user}->name,
        'conditions.0.args.0' => $c->stash->{user}->id,
        'conditions.1.field' => 'status',
        'conditions.1.operator' => '=',
        'conditions.1.args' => $STATUS_DELETED,
    };

    $c->stash(
        current_view => 'Node',
        component_path => 'user/UserEdits',
        component_props => {
            editCountLimit => $c->stash->{edit_count_limit},
            edits => to_json_array($edits),
            pager => serialize_pager($c->stash->{pager}),
            refineUrlArgs => $refine_url_args,
            user => $user,
        },
    );
}

sub accepted : Chained('/user/load') PathPart('edits/accepted') RequireAuth HiddenOnMirrors {
    my ($self, $c) = @_;
    my $edits = $self->_edits($c, sub {
        return $c->model('Edit')->find({
            editor => $c->stash->{user}->id,
            status => $STATUS_APPLIED,
            autoedit => 0
        }, shift, shift);
    });

    my $user = to_json_object($c->stash->{user});
    my $refine_url_args = {
        form_only => 'yes',
        auto_edit_filter => 0,
        order => 'desc',
        negation => 0,
        combinator => 'and',
        'conditions.0.field' => 'editor',
        'conditions.0.operator' => '=',
        'conditions.0.name' => $c->stash->{user}->name,
        'conditions.0.args.0' => $c->stash->{user}->id,
        'conditions.1.field' => 'status',
        'conditions.1.operator' => '=',
        'conditions.1.args' => $STATUS_APPLIED,
    };

    $c->stash(
        current_view => 'Node',
        component_path => 'user/UserEdits',
        component_props => {
            editCountLimit => $c->stash->{edit_count_limit},
            edits => to_json_array($edits),
            pager => serialize_pager($c->stash->{pager}),
            refineUrlArgs => $refine_url_args,
            user => $user,
        },
    );
}

sub failed : Chained('/user/load') PathPart('edits/failed') RequireAuth HiddenOnMirrors {
    my ($self, $c) = @_;
    my $edits = $self->_edits($c, sub {
        return $c->model('Edit')->find({
            editor => $c->stash->{user}->id,
            status => [ $STATUS_FAILEDDEP, $STATUS_FAILEDPREREQ,
                        $STATUS_ERROR, $STATUS_NOVOTES ]
        }, shift, shift);
    });

    my $user = to_json_object($c->stash->{user});
    my $refine_url_args = {
        form_only => 'yes',
        auto_edit_filter => '',
        order => 'desc',
        negation => 0,
        combinator => 'and',
        'conditions.0.field' => 'editor',
        'conditions.0.operator' => '=',
        'conditions.0.name' => $c->stash->{user}->name,
        'conditions.0.args.0' => $c->stash->{user}->id,
        'conditions.1.field' => 'status',
        'conditions.1.operator' => '=',
        'conditions.1.args.0' => $STATUS_FAILEDDEP,
        'conditions.1.args.1' => $STATUS_FAILEDPREREQ,
        'conditions.1.args.2' => $STATUS_ERROR,
        'conditions.1.args.3' => $STATUS_NOVOTES,
    };

    $c->stash(
        current_view => 'Node',
        component_path => 'user/UserEdits',
        component_props => {
            editCountLimit => $c->stash->{edit_count_limit},
            edits => to_json_array($edits),
            pager => serialize_pager($c->stash->{pager}),
            refineUrlArgs => $refine_url_args,
            user => $user,
        },
    );
}

sub rejected : Chained('/user/load') PathPart('edits/rejected') RequireAuth HiddenOnMirrors {
    my ($self, $c) = @_;
    my $edits = $self->_edits($c, sub {
        return $c->model('Edit')->find({
            editor => $c->stash->{user}->id,
            status => [ $STATUS_FAILEDVOTE ]
        }, shift, shift);
    });

    my $user = to_json_object($c->stash->{user});
    my $refine_url_args = {
        form_only => 'yes',
        auto_edit_filter => '',
        order => 'desc',
        negation => 0,
        combinator => 'and',
        'conditions.0.field' => 'editor',
        'conditions.0.operator' => '=',
        'conditions.0.name' => $c->stash->{user}->name,
        'conditions.0.args.0' => $c->stash->{user}->id,
        'conditions.1.field' => 'status',
        'conditions.1.operator' => '=',
        'conditions.1.args' => $STATUS_FAILEDVOTE,
    };

    $c->stash(
        current_view => 'Node',
        component_path => 'user/UserEdits',
        component_props => {
            editCountLimit => $c->stash->{edit_count_limit},
            edits => to_json_array($edits),
            pager => serialize_pager($c->stash->{pager}),
            refineUrlArgs => $refine_url_args,
            user => $user,
        },
    );
}

sub autoedits : Chained('/user/load') PathPart('edits/autoedits') RequireAuth HiddenOnMirrors {
    my ($self, $c) = @_;
    my $edits = $self->_edits($c, sub {
        return $c->model('Edit')->find({
            editor => $c->stash->{user}->id,
            autoedit => 1
        }, shift, shift);
    });

    my $user = to_json_object($c->stash->{user});
    my $refine_url_args = {
        form_only => 'yes',
        auto_edit_filter => 1,
        order => 'desc',
        negation => 0,
        combinator => 'and',
        'conditions.0.field' => 'editor',
        'conditions.0.operator' => '=',
        'conditions.0.name' => $c->stash->{user}->name,
        'conditions.0.args.0' => $c->stash->{user}->id,
    };

    $c->stash(
        current_view => 'Node',
        component_path => 'user/UserEdits',
        component_props => {
            editCountLimit => $c->stash->{edit_count_limit},
            edits => to_json_array($edits),
            pager => serialize_pager($c->stash->{pager}),
            refineUrlArgs => $refine_url_args,
            user => $user,
        },
    );
}

sub applied : Chained('/user/load') PathPart('edits/applied') RequireAuth HiddenOnMirrors {
    my ($self, $c) = @_;
    my $edits = $self->_edits($c, sub {
        return $c->model('Edit')->find({
            editor => $c->stash->{user}->id,
            status => $STATUS_APPLIED,
        }, shift, shift);
    });

    my $user = to_json_object($c->stash->{user});
    my $refine_url_args = {
        form_only => 'yes',
        auto_edit_filter => '',
        order => 'desc',
        negation => 0,
        combinator => 'and',
        'conditions.0.field' => 'editor',
        'conditions.0.operator' => '=',
        'conditions.0.name' => $c->stash->{user}->name,
        'conditions.0.args.0' => $c->stash->{user}->id,
        'conditions.1.field' => 'status',
        'conditions.1.operator' => '=',
        'conditions.1.args' => $STATUS_APPLIED,
    };

    $c->stash(
        current_view => 'Node',
        component_path => 'user/UserEdits',
        component_props => {
            editCountLimit => $c->stash->{edit_count_limit},
            edits => to_json_array($edits),
            pager => serialize_pager($c->stash->{pager}),
            refineUrlArgs => $refine_url_args,
            user => $user,
        },
    );
}

sub all : Chained('/user/load') PathPart('edits') RequireAuth HiddenOnMirrors {
    my ($self, $c) = @_;
    my $edits = $self->_edits($c, sub {
        return $c->model('Edit')->find({
            editor => $c->stash->{user}->id
        }, shift, shift);
    });

    my $user = to_json_object($c->stash->{user});
    my $refine_url_args = {
        form_only => 'yes',
        auto_edit_filter => '',
        order => 'desc',
        negation => 0,
        combinator => 'and',
        'conditions.0.field' => 'editor',
        'conditions.0.operator' => '=',
        'conditions.0.name' => $c->stash->{user}->name,
        'conditions.0.args.0' => $c->stash->{user}->id,
    };

    $c->stash(
        current_view => 'Node',
        component_path => 'user/UserEdits',
        component_props => {
            editCountLimit => $c->stash->{edit_count_limit},
            edits => to_json_array($edits),
            pager => serialize_pager($c->stash->{pager}),
            refineUrlArgs => $refine_url_args,
            user => $user,
        },
    );
}

sub votes : Chained('/user/load') PathPart('votes') RequireAuth HiddenOnMirrors {
    my ($self, $c) = @_;
    my $edits = $self->_edits($c, sub {
        return $c->model('Edit')->find_by_voter($c->stash->{user}->id, shift, shift);
    });

    my $user = to_json_object($c->stash->{user});

    $c->stash(
        current_view => 'Node',
        component_path => 'user/UserEdits',
        component_props => {
            editCountLimit => $c->stash->{edit_count_limit},
            edits => to_json_array($edits),
            pager => serialize_pager($c->stash->{pager}),
            user => $user,
            voter => $user,
        },
    );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
