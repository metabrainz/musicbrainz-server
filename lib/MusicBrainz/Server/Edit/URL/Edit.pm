package MusicBrainz::Server::Edit::URL::Edit;
use 5.10.0;
use Moose;

use Clone qw( clone );
use MooseX::Types::Moose qw( Int Str Bool );
use MooseX::Types::Structured qw( Dict Optional );

use MusicBrainz::Server::Constants qw( $EDIT_URL_EDIT );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Edit::Utils qw( changed_display_data );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( l N_l );

no if $] >= 5.018, warnings => "experimental::smartmatch";

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::URL';
with 'MusicBrainz::Server::Edit::CheckForConflicts';

use aliased 'MusicBrainz::Server::Entity::URL';

sub edit_name { N_l('Edit URL') }
sub edit_type { $EDIT_URL_EDIT }
sub _edit_model { 'URL' }
sub edit_template_react { 'EditUrl' }
sub url_id { shift->entity_id }

sub change_fields
{
    return Dict[
        url => Optional[Str],
        description => Nullable[Str],
    ];
}

has '+data' => (
    isa => Dict[
        entity => Dict[
            id => Int,
            gid => Optional[Str],
            name => Str
        ],
        old => change_fields(),
        new => change_fields(),
        affects => Optional[Int],
        is_merge => Optional[Bool],
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        URL => [ $self->url_id ]
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    my $data = changed_display_data($self->data, $loaded,
        uri => 'url',
        description => 'description'
    );
    $data->{url} = to_json_object(
        $loaded->{URL}{ $self->url_id } ||
        URL->new(
            id => $self->url_id,
            url => $self->data->{entity}{name},
        )
    );
    $data->{isMerge} = boolean_to_json($self->data->{is_merge});
    $data->{affects} = $self->data->{affects};

    return $data;
}

after initialize => sub {
    my ($self) = @_;
    my $entity = $self->current_instance;
    $self->c->model('Relationship')->load($entity);
    $self->data->{affects} = scalar @{ $entity->relationships };
};

override allow_auto_edit => sub {
    my $self = shift;
    return 0 unless defined $self->data->{old}{url} && defined $self->data->{new}{url};
    return ($self->data->{old}{url} =~ s/^http:/https:/r) eq $self->data->{new}{url};
};

around accept => sub {
    my ($orig, $self) = @_;

    MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
        'This URL has already been merged into another URL'
    ) unless $self->c->model('URL')->get_by_id($self->url_id);

    my $new_id = $self->c->model( $self->_edit_model )->update(
        $self->entity_id,
        $self->merge_changes
    );

    $self->data->{entity}{id} = $new_id;

    # Check for any releases that might need updating
    $self->c->model('CoverArt')->url_updated($new_id);
};

after insert => sub {
    my ($self) = @_;

    # If the target URL exists, then this edit must not be an auto edit (as it
    # would produce a merge).
    $self->data->{is_merge} = 0;
    if (my $new_url = $self->data->{new}{url}) {
        if ($self->c->model('URL')->find_by_url($new_url)) {
            $self->data->{is_merge} = 1;
            $self->auto_edit(0);
        }
    }
};

sub current_instance {
    my $self = shift;
    $self->c->model('URL')->get_by_id($self->url_id),
}

around extract_property => sub {
    my ($orig, $self) = splice(@_, 0, 2);
    my ($property, $ancestor, $current, $new) = @_;
    given ($property) {
        when ('url') {
            return (
                [ $ancestor->{url}, $ancestor->{url} ],
                [ $current->url->as_string, $current->url->as_string ],
                [ $new->{url}, $new->{url} ]
            );
        }

        default {
            return ($self->$orig(@_));
        }
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
