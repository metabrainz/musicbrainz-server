package MusicBrainz::Server::Controller::Role::EditListing;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

use MusicBrainz::Server::Data::Utils qw( model_to_type load_everything_for_edits );
use MusicBrainz::Server::Constants qw( :edit_status );

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
    $c->stash(
        template => 'entity/edits.tt',
        all_edits => 1,
        refine_url_args => {
            auto_edit_filter => '',
            order => 'desc',
            negation => 0,
            combinator => 'and',
            'conditions.0.field' => model_to_type( $self->{model} ),
            'conditions.0.operator' => '=',
            'conditions.0.name' => $c->stash->{ $self->{entity_name} }->name,
            'conditions.0.args.0' => $c->stash->{ $self->{entity_name} }->id,
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

    $c->stash(
        template => 'entity/edits.tt',
        all_edits => 0,
        refine_url_args => {
            auto_edit_filter => '',
            order => 'desc',
            negation => 0,
            combinator => 'and',
            'conditions.0.field' => model_to_type( $self->{model} ),
            'conditions.0.operator' => '=',
            'conditions.0.name' => $c->stash->{ $self->{entity_name} }->name,
            'conditions.0.args.0' => $c->stash->{ $self->{entity_name} }->id,
            'conditions.1.field' => 'status',
            'conditions.1.operator' => '=',
            'conditions.1.args' => $STATUS_OPEN,
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
