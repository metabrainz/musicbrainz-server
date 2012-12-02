package MusicBrainz::Server::Edit::Release::ChangeQuality;
use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Edit::Utils qw( conditions_without_autoedit );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_CHANGE_QUALITY );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Release';

use aliased 'MusicBrainz::Server::Entity::Release';

sub edit_name { N_l('Change release quality') }
sub edit_type { $EDIT_RELEASE_CHANGE_QUALITY }
sub release_id { shift->data->{release}{id} }

method alter_edit_pending
{
    return {
        Release => [ $self->release_id ],
    }
}

sub change_fields
{
    return Dict[
        quality => Int,
    ]
}

has '+data' => (
    isa => Dict[
        release => Dict[
            id => Int,
            name => Str
        ],
        old     => change_fields(),
        new     => change_fields()
    ]
);

method foreign_keys
{
    return {
        Release => { $self->release_id => ['ArtistCredit'] },
    }
}

method build_display_data ($loaded)
{
    return {
        release => $loaded->{Release}{ $self->release_id }
            || Release->new( name => $self->data->{release}{name} ),
        quality => {
            old => $self->data->{old}{quality},
            new => $self->data->{new}{quality},
        }
    }
}

method initialize (%opts)
{
    my $release = $opts{to_edit} or die 'Need a release to change quality';

    MusicBrainz::Server::Edit::Exceptions::NoChanges->throw
          if $release->quality == $opts{quality};

    $self->data({
        release => {
            id => $release->id,
            name => $release->name
        },
        old => { quality => $release->quality },
        new => { quality => $opts{quality} },
    });
}


method accept
{
    $self->c->model('Release')->update(
        $self->release_id,
        { quality => $self->data->{new}{quality} }
    );
}

around edit_conditions => sub {
    my ($orig, $self, @args) = @_;
    return conditions_without_autoedit($self->$orig(@args));
};

no Moose;
__PACKAGE__->meta->make_immutable;
