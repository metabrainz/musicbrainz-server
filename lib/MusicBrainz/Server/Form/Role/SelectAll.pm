package MusicBrainz::Server::Form::Role::SelectAll;
use Moose::Role;

use List::UtilsBy qw( sort_by );
use MusicBrainz::Server::Translation qw( l );

requires 'ctx';

sub _select_all
{
    my ($self, $model, %opts) = @_;
    my $model_ref = ref($model) ? $model : $self->ctx->model($model);

    my $sort_by_accessor = $opts{sort_by_accessor} // $model_ref->sort_in_forms;
    my $accessor = $opts{accessor} // 'l_name';
    my $coll = $self->ctx->get_collator();

    my @sorted = sort_by {
        $sort_by_accessor ? $coll->getSortKey(l($_->$accessor)) : ''
    } $model_ref->get_all;

    return [ map {
        $_->id => l($_->$accessor)
    } @sorted];
}

1;
