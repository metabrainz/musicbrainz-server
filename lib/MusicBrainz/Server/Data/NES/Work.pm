package MusicBrainz::Server::Data::NES::Work;
use feature 'switch';
use Moose;

use List::UtilsBy qw( partition_by );
use MusicBrainz::Server::Data::Utils qw( partial_date_to_hash );
use MusicBrainz::Server::Entity::NES::Relationship;
use MusicBrainz::Server::Entity::Work;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( boolean );

with 'MusicBrainz::Server::Data::Role::NES';
with 'MusicBrainz::Server::Data::NES::CoreEntity' => {
    root => '/work'
};

around create => sub {
    my ($orig, $self, $edit, $editor, $tree) = @_;

    $tree->annotation('') unless $tree->annotation_set;
    $tree->aliases([]) unless $tree->aliases_set;
    $tree->relationships([]) unless $tree->relationships_set;

    $self->$orig($edit, $editor, $tree);
};

sub view_tree {
    my ($self, $revision) = @_;

    return MusicBrainz::Server::Entity::Tree::Work->new(
        work => $revision,
        iswcs => $self->get_iswcs($revision),
        annotation => $self->get_annotation($revision),
        aliases => $self->get_aliases($revision)
    );
}

sub tree_to_json {
    my ($self, $tree) = @_;

    return (
        work => do {
            my $work = $tree->work;
            {
                 type => $work->type_id,
                 language => $work->language_id,
                 name => $work->name,
                 comment => $work->comment
            }
        },
        iswcs => [
            map +{ iswc => $_->iswc }, @{ $tree->iswcs }
        ],
        annotation => $tree->annotation,
        aliases => [
            map +{
                name => $_->name,
                'sort-name' => $_->sort_name,
                'begin-date' => partial_date_to_hash($_->begin_date),
                'end-date' => partial_date_to_hash($_->end_date),
                ended => $_->ended,
                'primary-for-locale' => boolean($_->primary_for_locale),
                type => $_->type_id,
                locale => $_->locale
            }, @{ $tree->aliases }
        ],
        relationships => {
            partition_by { $_->{target_type} }
                map +{
                    target => $_->target->gid,
                    type => $_->link_type_id,
                    target_type => $_->target_type
                }, @{ $tree->relationships }
        }
    );
}

sub map_core_entity {
    my ($self, $response) = @_;
    my %data = %{ $response->{data} };
    return MusicBrainz::Server::Entity::Work->new(
        name => $data{name},
        comment => $data{comment},
        type_id => $data{type},
        language_id => $data{language},

        gid => $response->{mbid},
        revision_id => $response->{revision}
    );
}

sub tags {
    my $self = shift;
    $self->c->model('Work')->tags;
}

sub get_aliases {
    my ($self, $work) = @_;
    my $response = $self->request('/work/view-aliases', {
        revision => $work->revision_id
    });
    return [
        map {
            MusicBrainz::Server::Entity::Alias->new(
                name => $_->{name},
                sort_name => $_->{'sort-name'},
                locale => $_->{locale},
                type_id => $_->{type},
                begin_date => MusicBrainz::Server::Entity::PartialDate->new($_->{begin_date}),
                end_date => MusicBrainz::Server::Entity::PartialDate->new($_->{end_date}),
                ended => $_->{ended},
                primary_for_locale => $_->{'primary-for-locale'}
            )
        } @$response
    ]
}

sub get_iswcs {
    my ($self, $revision) = @_;
    warn "Unimplemented";
    return [];
}

sub get_annotation {
    my ($self, $revision) = @_;
    return $self->request(
        '/work/view-annotation',
        { revision => $revision->revision_id }
    )->{annotation};
}

sub get_relationships {
    my ($self, $revision) = @_;
    my @rels =
        map {
            my $rel = $_;
            my $target;
            given ($rel->{'target-type'}) {
                when (/url/) {
                    $target = $self->c->model('NES::URL')->get_by_gid($rel->{target});
                }
            }

            MusicBrainz::Server::Entity::NES::Relationship->new(
                target => $target,
                target_gid => $rel->{target},
                link => MusicBrainz::Server::Entity::Link->new(
                    type_id => $rel->{type},
                    direction => $MusicBrainz::Server::Entity::NES::Relationship::DIRECTION_BACKWARD
                ),
                target_type => $rel->{'target-type'},
            );
        } @{
            $self->request(
                '/work/view-relationships',
                { revision => $revision->revision_id }
            )
        };

    $self->c->model('LinkType')->load(map { $_->link } @rels);

    return \@rels;
}

sub load_annotation {
    my ($self, $work) = @_;
    $work->latest_annotation(
        MusicBrainz::Server::Entity::Annotation->new(
            text => $self->get_annotation($work)));
}

sub is_empty {
    my ($self, $work) = @_;
    return $self->request(
        '/work/eligible-for-cleanup',
        { revision => $work->revision_id }
    )->{eligible};
}

sub load_relationships {
    my ($self, @works) = @_;
    for my $work (@works) {
        $work->relationships($self->get_relationships($work));
    }
}

__PACKAGE__->meta->make_immutable;
1;
