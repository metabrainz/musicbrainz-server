package MusicBrainz::Server::Edit::Alias::Edit;
use Moose;
use MooseX::ABC;

use Clone 'clone';
use Moose::Util::TypeConstraints qw( as subtype find_type_constraint );
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Validation qw( normalise_strings );

extends 'MusicBrainz::Server::Edit::WithDifferences';

sub _alias_model { die 'Not implemented' }

subtype 'AliasHash'
    => as Dict[
        name   => Str,
        locale => Nullable[Str]
    ];

has '+data' => (
    isa => Dict[
        alias_id => Int,
        entity_id => Int,
        new => find_type_constraint('AliasHash'),
        old => find_type_constraint('AliasHash'),
    ]
);

sub alias_id { shift->data->{alias_id} }

sub foreign_keys
{
    my $self = shift;
    my $model = type_to_model($self->_alias_model->type);
    return {
        $model => [ $self->data->{entity_id} ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $type = $self->_alias_model->type;
    my $model = type_to_model($type);

    return {
        alias => {
            new => $self->data->{new}{name},
            old => $self->data->{old}{name}
        },
        locale => {
            new => $self->data->{new}{locale},
            old => $self->data->{old}{locale}
        },
        $type => $loaded->{$model}{ $self->data->{entity_id} }
    };
}

sub accept
{
    my $self = shift;
    my $model = $self->_alias_model;
    $model->update($self->data->{alias_id}, clone($self->data->{new}));
}

sub initialize
{
    my ($self, %opts) = @_;
    my $alias = delete $opts{alias};
    die "You must specify the alias object to edit" unless defined $alias;
    $self->data({
        alias_id => $alias->id,
        entity_id => delete $opts{entity_id},
        $self->_change_data($alias, %opts)
    });
}


__PACKAGE__->meta->make_immutable;
no Moose;

1;
