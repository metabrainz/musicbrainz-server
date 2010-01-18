package MusicBrainz::Server::Edit::Medium::Edit;
use Moose;

use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_EDIT );
use MusicBrainz::Server::Edit::Types qw( Nullable );

extends 'MusicBrainz::Server::Edit::Generic::Edit';

sub edit_type { $EDIT_MEDIUM_EDIT }
sub edit_name { 'Edit medium' }
sub _edit_model { 'Medium' }
sub medium_id { shift->medium_id }

sub change_fields
{
    return Dict[
        position => Optional[Int],
        name => Nullable[Str],
        format_id => Nullable[Int],
        tracklist_id => Optional[Int],
    ];
}

has '+data' => (
    isa => Dict[
        entity_id => Int,
        old => change_fields(),
        new => change_fields()
    ]
);

sub foreign_keys {
    my $self = shift;
    if (exists $self->data->{new}{format_id}) {
        return {
            MediumFormat => {
                $self->data->{new}{format_id} => [],
                $self->data->{old}{format_id} => [],
            }
        }
    }
    else {
        return { };
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    my $data = {};

    if (exists $self->data->{new}{format_id}) {
        $data->{format} = {
            new => $loaded->{MediumFormat}->{ $self->data->{new}{format_id} },
            old => $loaded->{MediumFormat}->{ $self->data->{old}{format_id} }
        };
    }

    for my $attribute (qw( name position )) {
        if (exists $self->data->{new}{$attribute}) {
            $data->{$attribute} = {
                new => $self->data->{new}{$attribute},
                old => $self->data->{old}{$attribute},
            };
        }
    }

    return $data;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
