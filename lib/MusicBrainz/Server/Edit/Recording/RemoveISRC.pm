package MusicBrainz::Server::Edit::Recording::RemoveISRC;
use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_CREATE $EDIT_RECORDING_REMOVE_ISRC );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

use aliased 'MusicBrainz::Server::Entity::Recording';
use aliased 'MusicBrainz::Server::Entity::ISRC';

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities';
with 'MusicBrainz::Server::Edit::Recording';
with 'MusicBrainz::Server::Edit::Role::AllowAmending' => {
    create_edit_type => $EDIT_RECORDING_CREATE,
    entity_type => 'recording',
};

sub edit_name { N_l('Remove ISRC') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_RECORDING_REMOVE_ISRC }
sub edit_template { 'RemoveIsrc' }

sub recording_id { shift->data->{recording}{id} }

has '+data' => (
    isa => Dict[
        isrc => Dict[
            id   => Int,
            isrc => Str
        ],
        recording => Dict[
            id   => Int,
            name => Str
        ]
    ]
);

method alter_edit_pending
{
    return {
        Recording => [ $self->data->{recording}{id} ],
        ISRC      => [ $self->data->{isrc}{id} ]
    }
}

method foreign_keys
{
    return {
        ISRC      => { $self->data->{isrc}{id} => [ 'Recording ArtistCredit' ] },
        Recording => { $self->data->{recording}{id} => [ 'ArtistCredit' ] },
    }
}

method build_display_data ($loaded)
{
    my $isrc = $loaded->{ISRC}{ $self->data->{isrc}{id} } ||
        ISRC->new(
            isrc => $self->data->{isrc}{isrc},
            recording => $loaded->{Recording}{ $self->data->{recording}{id} } //
                         Recording->new(
                             id => $self->data->{recording}{id},
                             name => $self->data->{recording}{name}
                         ),
            recording_id => $self->data->{recording}{id},
        );

    return { isrc => to_json_object($isrc) };
}

sub initialize
{
    my ($self, %opts) = @_;

    my $isrc = $opts{isrc} or die q(Required 'isrc' object missing);
    $self->c->model('Recording')->load($isrc) unless defined $isrc->recording;
    $self->data({
        isrc => {
            id   => $isrc->id,
            isrc => $isrc->isrc,
        },
        recording => {
            id   => $isrc->recording->id,
            name => $isrc->recording->name
        }
    });
}

method accept
{
    $self->c->model('ISRC')->delete( $self->data->{isrc}{id} );
}

around allow_auto_edit => sub {
    my ($orig, $self, @args) = @_;

    return 1 if $self->can_amend($self->recording_id);

    return $self->$orig(@args);
};

no Moose;
__PACKAGE__->meta->make_immutable;
