package MusicBrainz::Server::Edit::Historic::EditLinkType;
use Moose;
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_EDIT_LINK_TYPE );

use MusicBrainz::Server::Data::Utils qw( remove_equal );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name     { 'Edit relationship type' }
sub edit_type     { $EDIT_HISTORIC_EDIT_LINK_TYPE  }
sub historic_type { 37 }
sub ngs_class     { 'MusicBrainz::Server::Edit::Relationship::EditLinkType' }

sub upgrade_values
{
    my ($self, $values, $prefix) = @_;
    $values = {
        map { substr($_, length($prefix)) => $values->{$_} }
            grep { /^$prefix/ } keys %$values
    };

    my ($junk, @attributes) = split /=/, $values->{attribute};
    my $all_attrs = join '=', @attributes;
    @attributes = split / /, $all_attrs;

    my $mapped = {
        parent              => $values->{parent},
        name                => $values->{name},
        child_order         => $values->{childorder},
        link_phrase         => $values->{linkphrase},
        reverse_link_phrase => $values->{rlinkphrase},
        description         => $values->{description},
        attributes          => [
            map {
                my ($name, $min_max) = split /=/, $_;
                my ($min, $max) = split /-/, $min_max;

                +{
                    name => $name,
                    min  => $min,
                    max  => $max
                }
            } @attributes
        ]
    };

    $mapped->{short_link_phrase} = $values->{shortlinkphrase}
        if exists $values->{shortlinkphrase};

    return $mapped;
}

augment 'upgrade' => sub {
    my $self = shift;

    my $old = $self->upgrade_values($self->new_value, 'old_');
    my $new = $self->upgrade_values($self->new_value, '');

    remove_equal($old, $new);

    my $data = {
        types   => [ split /-/, $self->new_value->{types} ],
        link_id => $self->row_id,
        old     => $old,
        new     => $new
    };

    use Devel::Dwarn;
    Dwarn $data;

    return $data;
};

no Moose;
__PACKAGE__->meta->make_immutable;
