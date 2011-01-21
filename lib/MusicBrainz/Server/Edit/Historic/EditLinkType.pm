package MusicBrainz::Server::Edit::Historic::EditLinkType;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_EDIT_LINK_TYPE );
use MusicBrainz::Server::Data::Utils qw( remove_equal );
use MusicBrainz::Server::Translation qw ( l ln );

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name     { l('Edit relationship type') }
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

    my @attributes = split / /, $self->new_value->{attribute};

    my $mapped = {
        parent_id           => $values->{parent},
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
                    min  => $min || 0,
                    max  => $max || 0
                }
            } @attributes
        ]
    };

    $mapped->{short_link_phrase} = $values->{shortlinkphrase}
        if exists $values->{shortlinkphrase};

    return $mapped;
}

sub do_upgrade {
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

    return $data;
}

1;
