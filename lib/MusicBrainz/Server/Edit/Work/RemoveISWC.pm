package MusicBrainz::Server::Edit::Work::RemoveISWC;
use Moose;
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw(
    $EDIT_WORK_CREATE
    $EDIT_WORK_REMOVE_ISWC
);
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

use aliased 'MusicBrainz::Server::Entity::Work';
use aliased 'MusicBrainz::Server::Entity::ISWC';

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities';
with 'MusicBrainz::Server::Edit::Work';
with 'MusicBrainz::Server::Edit::Role::AllowAmending' => {
    create_edit_type => $EDIT_WORK_CREATE,
    entity_type => 'work',
};

sub edit_name { N_l('Remove ISWC') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_WORK_REMOVE_ISWC }
sub edit_template_react { 'RemoveIswc' }

sub work_id { shift->data->{work}{id} }

has '+data' => (
    isa => Dict[
        iswc => Dict[
            id   => Int,
            iswc => Str
        ],
        work => Dict[
            id   => Int,
            name => Str
        ]
    ]
);

sub alter_edit_pending {
    my ($self) = @_;
    return {
        Work => [ $self->data->{work}{id} ],
        ISWC => [ $self->data->{iswc}{id} ]
    }
}

sub foreign_keys {
    my ($self) = @_;
    return {
        ISWC => { $self->data->{iswc}{id} => [ 'Work' ] },
        Work => [ $self->data->{work}{id} ],
    }
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my $iswc = $loaded->{ISWC}{ $self->data->{iswc}{id} } ||
        ISWC->new(
            iswc => $self->data->{iswc}{iswc},
            work => $loaded->{Work}{ $self->data->{work}{id} } //
                    Work->new(
                        id => $self->data->{work}{id},
                        name => $self->data->{work}{name}
                    ),
            work_id => $self->data->{work}{id},
        );

    return { iswc => to_json_object($iswc) };
}

sub initialize {
    my ($self, %opts) = @_;

    my $iswc = $opts{iswc} or die "Required 'iswc' object missing";
    $self->c->model('Work')->load($iswc) unless defined $iswc->work;
    $self->data({
        iswc => {
            id   => $iswc->id,
            iswc => $iswc->iswc,
        },
        work => {
            id   => $iswc->work->id,
            name => $iswc->work->name
        }
    });
}

sub accept {
    my $self = shift;
    $self->c->model('ISWC')->delete( $self->data->{iswc}{id} );
}

around allow_auto_edit => sub {
    my ($orig, $self, @args) = @_;

    return 1 if $self->can_amend($self->work_id);

    return $self->$orig(@args);
};

no Moose;
__PACKAGE__->meta->make_immutable;
