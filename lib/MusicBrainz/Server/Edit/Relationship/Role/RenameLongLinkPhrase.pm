package MusicBrainz::Server::Edit::Relationship::Role::RenameLongLinkPhrase;
use Moose::Role;

requires 'initialize';

around initialize => sub {
    my ($orig, $self, %opts) = @_;
    $opts{short_link_phrase} = delete $opts{long_link_phrase}
        if exists $opts{long_link_phrase};

    $self->$orig(%opts);
};

1;
