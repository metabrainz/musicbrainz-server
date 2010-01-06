package MusicBrainz::Server::Edit::URL::Edit;
use Moose;

use Moose::Util::TypeConstraints qw( subtype as find_type_constraint );
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_URL_EDIT );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Edit::Utils qw( changed_display_data );

extends 'MusicBrainz::Server::Edit::WithDifferences';

sub edit_name { 'Edit URL' }
sub edit_type { $EDIT_URL_EDIT }

sub alter_edit_pending { { URL => [ shift->url_id ] } }

subtype 'UrlHash' => as Dict[
    url => Optional[Str],
    description => Nullable[Str],
];

has '+data' => (
    isa => Dict[
        url_id => Int,
        old => find_type_constraint('UrlHash'),
        new => find_type_constraint('UrlHash'),
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
    $data->{url} = $loaded->{URL}->{ $self->url_id };

    return $data;
}

sub url_id { shift->data->{url_id} }

sub initialize
{
    my ($self, %opts) = @_;
    my $url = delete $opts{url_entity};
    confess "You must specify the url object to edit" unless defined $url;

    $self->data({
        url_id => $url->id,
        $self->_change_data($url, %opts)
    });
};

sub accept
{
    my $self = shift;
    $self->c->model('URL')->update($self->url_id, $self->data->{new});
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
