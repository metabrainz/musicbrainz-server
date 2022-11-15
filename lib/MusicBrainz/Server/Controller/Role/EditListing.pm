package MusicBrainz::Server::Controller::Role::EditListing;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

use MusicBrainz::Server::Data::Utils qw(
    boolean_to_json
    load_everything_for_edits
    model_to_type
);
use MusicBrainz::Server::Constants qw( :edit_status );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Entity::Util::JSON qw(
    to_json_array
    to_json_object
);

requires '_load_paged';

sub edits : Chained('load') PathPart
{
    my ($self, $c) = @_;
    $self->_list($c, sub {
        my ($type, $entity) = @_;
        return sub {
            my ($limit, $offset) = @_;
            $c->model('Edit')->find({ $type => $entity->id }, $limit, $offset);
        }
    });

    my $refine_url_args = {
        form_only => 'yes',
        auto_edit_filter => '',
        order => 'desc',
        negation => 0,
        combinator =>'and',
        'conditions.0.field' => model_to_type( $self->{model} ),
        'conditions.0.operator' => '=',
        'conditions.0.name' => $c->stash->{ $self->{entity_name} }->name,
        'conditions.0.args.0' => $c->stash->{ $self->{entity_name} }->id,
    };

    $c->stash(
        current_view => 'Node',
        component_path => 'entity/Edits',
        component_props => {
            editCountLimit => $c->stash->{edit_count_limit},
            edits => to_json_array($c->stash->{edits}),
            entity => to_json_object($c->stash->{ $self->{entity_name} }),
            pager => serialize_pager($c->stash->{pager}),
            refineUrlArgs => $refine_url_args,
            showingOpenOnly => boolean_to_json(0),
        },
    );
}

sub open_edits : Chained('load') PathPart
{
    my ($self, $c) = @_;
    $self->_list($c, sub {
        my ($type, $entity) = @_;
        return sub {
            my ($limit, $offset) = @_;
            $c->model('Edit')->find({ $type => $entity->id, status => $STATUS_OPEN }, $limit, $offset);
        }
    });

    my $refine_url_args = {
        form_only => 'yes',
        auto_edit_filter => '',
        order => 'desc',
        negation => 0,
        combinator=>'and',
        'conditions.0.field' => model_to_type( $self->{model} ),
        'conditions.0.operator' => '=',
        'conditions.0.name' => $c->stash->{ $self->{entity_name} }->name,
        'conditions.0.args.0' => $c->stash->{ $self->{entity_name} }->id,
        'conditions.1.field' => 'status',
        'conditions.1.operator' => '=',
        'conditions.1.args' => $STATUS_OPEN,
    };

    $c->stash(
        current_view => 'Node',
        component_path => 'entity/Edits',
        component_props => {
            editCountLimit => $c->stash->{edit_count_limit},
            edits => to_json_array($c->stash->{edits}),
            entity => to_json_object($c->stash->{ $self->{entity_name} }),
            pager => serialize_pager($c->stash->{pager}),
            refineUrlArgs => $refine_url_args,
            showingOpenOnly => boolean_to_json(1),
        },
    );
}

sub _list {
    my ($self, $c, $find) = @_;

    my $type   = model_to_type( $self->{model} );
    my $entity = $c->stash->{ $self->{entity_name} };
    my $edits  = $self->_load_paged($c, $find->($type, $entity), limit => 50);

    $c->stash(
        edits => $edits, # stash early in case an ISE occurs
    );

    load_everything_for_edits($c, $edits);
}

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
