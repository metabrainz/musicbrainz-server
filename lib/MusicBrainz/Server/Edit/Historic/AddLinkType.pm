package MusicBrainz::Server::Edit::Historic::AddLinkType;
use Moose;

use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { l('Add relationship type') }
sub edit_type { 36 }
sub ngs_class { 'MusicBrainz::Server::Edit::Relationship::AddLinkType' }

augment 'upgrade' => sub
{
    my ($self) = @_;

    my ($junk, @attributes) = split /=/, $self->new_value->{attribute};
    my $all_attrs = join '=', @attributes;
    @attributes = split / /, $all_attrs;

    my %types = (
        track => 'recording',
        album => 'release',
    );

    my $data = {
        types               => [ map { $types{$_} || $_ } split /-/, $self->new_value->{types} ],
        name                => $self->new_value->{name},
        parent              => $self->new_value->{parent},
        gid                 => $self->new_value->{gid},
        link_phrase         => $self->new_value->{linkphrase},
        reverse_link_phrase => $self->new_value->{rlinkphrase},
        description         => $self->new_value->{description},
        attributes => [
            map {
                my ($name, $min_max) = split /=/, $_;
                my ($min, $max) = split /-/, $_;
                +{
                    name => $name,
                    min  => $min,
                    max  => $max
                }
            } @attributes
        ]
    };

    $data->{short_link_phrase} = $self->new_value->{shortlinkphrase}
        if exists $self->new_value->{shortlinkphrase};

    $data->{priority} = $self->new_value->{priority}
        if exists $self->new_value->{priority};

    $data->{child_order} = $self->new_value->{childorder}
        if exists $self->new_value->{childorder};

    return $data;
};

no Moose;
__PACKAGE__->meta->make_immutable;
