package MusicBrainz::Server::Form;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+name' => ( required => 1 );
has '+html_prefix' => ( default => 1 );

sub submitted_and_valid
{
    my ($self, $params) = @_;
    return $self->process( params => $params) && $self->has_params;
}

sub _select_all
{
    my ($self, $model, $accessor) = @_;
    $accessor ||= 'name';
    return [ map {
        $_->id => $_->$accessor
    } $self->ctx->model($model)->get_all ];
}

1;
