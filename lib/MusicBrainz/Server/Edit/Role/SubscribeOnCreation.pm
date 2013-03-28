package MusicBrainz::Server::Edit::Role::SubscribeOnCreation;
use MooseX::Role::Parameterized;

parameter editor_subscription_preference => (
    isa => 'CodeRef',
    required => 1
);

role {
    my $params = shift;

    requires '_create_model', 'entity_id', 'c', 'editor_id';

    after post_insert => sub {
        my $self = shift;

        my $editor = $self->c->model('Editor')->get_by_id($self->editor_id);
        $self->c->model('Editor')->load_preferences($editor);

        if ($params->editor_subscription_preference->($editor->preferences)) {
            $self->c->model($self->_create_model)->subscription->subscribe($editor->id, $self->entity_id);
        }
    };
};

1;
