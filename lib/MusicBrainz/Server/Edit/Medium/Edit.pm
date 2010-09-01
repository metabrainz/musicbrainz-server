package MusicBrainz::Server::Edit::Medium::Edit;
use Moose;

use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_EDIT );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Validation 'normalise_strings';

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::Medium::RelatedEntities';

sub edit_type { $EDIT_MEDIUM_EDIT }
sub edit_name { 'Edit medium' }
sub _edit_model { 'Medium' }
sub medium_id { shift->data->{entity_id} }

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

sub allow_auto_edit
{
    my $self = shift;

    my ($old_name, $new_name) = normalise_strings($self->data->{old}{name},
                                                  $self->data->{new}{name});

    return 0 if $self->data->{old}{name} && $old_name ne $new_name;
    return 0 if $self->data->{old}{format_id};
    return 0 if exists $self->data->{old}{position};
    return 0 if exists $self->data->{old}{tracklist_id};

    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
