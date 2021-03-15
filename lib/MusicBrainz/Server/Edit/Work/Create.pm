package MusicBrainz::Server::Edit::Work::Create;
use Moose;

use MooseX::Types::Moose qw( ArrayRef Int Maybe Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_WORK_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( l N_l );

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities';
with 'MusicBrainz::Server::Edit::Work';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

use aliased 'MusicBrainz::Server::Entity::Work';

sub edit_name { N_l('Add work') }
sub edit_type { $EDIT_WORK_CREATE }
sub _create_model { 'Work' }
sub work_id { shift->entity_id }
sub edit_template_react { 'AddWork' }

has '+data' => (
    isa => Dict[
        name          => Str,
        comment       => Nullable[Str],
        type_id       => Nullable[Int],
        language_id   => Nullable[Int],
        languages     => Optional[ArrayRef[Int]],
        iswc          => Nullable[Str],
        attributes    => Optional[ArrayRef[Dict[
            attribute_text => Maybe[Str],
            attribute_value_id => Maybe[Int],
            attribute_type_id => Int
        ]]]
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Work => [ $self->entity_id ],
        WorkType => [ $self->data->{type_id} ],
        Language => [
            $self->data->{language_id},
            @{ $self->data->{languages} // [] },
        ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $data = $self->data;
    my $display = {
        name          => $data->{name},
        comment       => $data->{comment} // '',
        type          => $data->{type_id} && to_json_object($loaded->{WorkType}{ $data->{type_id} }),
        iswc          => $data->{iswc} // '',
        work          => to_json_object((defined($self->entity_id) &&
            $loaded->{Work}{ $self->entity_id }) ||
            Work->new( name => $self->data->{name} )
        ),
        ($data->{attributes} && @{ $data->{attributes} } ?
         ( attributes => { $self->grouped_attributes_by_type($data->{attributes}, 1) } ) : ()
        ),
    };

    if (defined $data->{language_id}) {
        my $language = $loaded->{Language}{$data->{language_id}};
        if ($language->iso_code_3 eq "zxx") {
            $language->name(l("[No lyrics]"));
        }
        $display->{language} = $language;
    }

    if (defined $data->{languages}) {
        $display->{languages} = [
            map {
                my $language = $loaded->{Language}{$_};
                if ($language && $language->iso_code_3 eq "zxx") {
                    $language->name(l("[No lyrics]"));
                }
                $language ? $language->name : l('[removed]')
            } @{ $data->{languages} }
        ];
    }

    return $display;
}

after insert => sub {
    my $self = shift;
    if (my $attributes = $self->data->{attributes}) {
        $self->c->model('Work')->set_attributes($self->entity_id, @$attributes);
    }
    if (my $languages = $self->data->{languages}) {
        $self->c->model('Work')->language->set($self->entity_id, @$languages);
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
