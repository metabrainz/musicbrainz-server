package MusicBrainz::Server::Controller::WS::1::Role::Relationships;
use Moose::Role;

before 'lookup' => sub {
    my ($self, $c) = @_;
    my $entity = $c->stash->{entity};
    $self->load_relationships($c, $entity);
};

sub load_relationships
{
    my ($self, $c, @entities) = @_;
    return unless ($c->stash->{inc}->has_rels);

    my $types = $c->stash->{inc}->get_rel_types;

    my @rels = $c->model('Relationship')->load_subset($types, @entities);
    my @releases;
    for my $relationship (map { @{$_->relationships} } @entities) {
        if ($relationship->target->isa('MusicBrainz::Server::Entity::Release')) {
            push @releases, $relationship->target;
        }
    }

    # We need to be able to display the release type
    $c->model('ReleaseGroup')->load(@releases);
    $c->model('ReleaseGroupType')->load(map { $_->release_group } @releases);
    $c->model('ReleaseStatus')->load(@releases);
    $c->model('Language')->load(@releases);
    $c->model('Script')->load(@releases);
}

1;
