package MusicBrainz::Server::Form::Role::CheckDuplicates;

use HTML::FormHandler::Moose::Role;
use MusicBrainz::Server::Translation 'l';
use namespace::autoclean;

requires 'dupe_model';

has_field 'not_dupe' => (
    type => 'Boolean',
    required_message => ' '
);

has 'duplicates' => (
    traits => [ 'Array' ],
    isa => 'ArrayRef',
    is => 'rw',
    default => sub { [] },
    handles => {
        has_duplicates => 'count'
    }
);

after 'validate' => sub
{
    my $self = shift;

    # Don't check for dupes if the not_dupe checkbox is ticked, or the
    # user hasn't changed the entity's name
    return if $self->init_object && $self->init_object->name eq $self->field('name')->value;

    # Load duplicates and filter out the currently edited entity
    my $entity_id = $self->init_object ? $self->init_object->id : 0;
    $self->duplicates([
        grep { $_->id != $entity_id }
        $self->dupe_model->find_by_name($self->field('name')->value)
    ]);

    my $comment_is_required = $self->filter_duplicates();
    $self->ctx->stash(comment_is_required => $comment_is_required);

    $self->field('not_dupe')->required($self->has_duplicates ? 1 : 0);
    $self->field('not_dupe')->validate_field;
    $self->field('comment')->required($self->has_duplicates && $comment_is_required ? 1 : 0);
    $self->field('comment')->validate_field;
};

sub filter_duplicates {
    return 1;
}

1;
