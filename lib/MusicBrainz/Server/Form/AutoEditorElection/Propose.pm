package MusicBrainz::Server::Form::AutoEditorElection::Propose;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub profile
{
    return {
        required => {
            editor => 'Text'
        }
    }
}

sub model_validate
{
    my $self = shift;
    my $c = $self->context;

    $c->model('User')->load({ username => $self->value('editor') })
        or $self->field('editor')->add_error('This editor does not exist');
}

1;