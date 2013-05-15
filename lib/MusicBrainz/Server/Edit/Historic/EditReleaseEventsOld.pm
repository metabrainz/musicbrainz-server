package MusicBrainz::Server::Edit::Historic::EditReleaseEventsOld;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw(
    $EDIT_HISTORIC_EDIT_RELEASE_EVENTS_OLD
);
use MusicBrainz::Server::Edit::Historic::Utils qw(
    upgrade_date
    upgrade_id
);
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Translation qw ( N_l );

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { N_l('Edit release events (historic)') }
sub historic_type { 29 }
sub edit_type     { $EDIT_HISTORIC_EDIT_RELEASE_EVENTS_OLD }
sub edit_template { 'edit_release_events' }

sub _additions { @{ shift->data->{additions} } }
sub _removals  { @{ shift->data->{removals } } }
sub _edits     { @{ shift->data->{edits    } } }

sub _release_ids
{
    my $self = shift;
    return map { $_->{release_id} }
        $self->_additions, $self->_removals, $self->_edits;
}

sub _build_related_entities
{
    my $self = shift;
    return {
        artist  => [ $self->artist_id ],
        release => [ $self->_release_ids ],
        label   => [
            map { $_->{label_id} }
                @{ $self->data->{additions} },
                @{ $self->data->{removals} },
                map {
                    $_->{old}, $_->{new}
                } @{ $self->data->{edits} },
        ]
    }
}

sub foreign_keys
{
    my $self = shift;
    my @everything = (
        (map { $_ } $self->_additions, $self->_removals),
        (map { $_->{old}, $_->{new} } $self->_edits),
    );

    return {
        Area         => [ map { $_->{country_id } } @everything ],
        Label        => [ map { $_->{label_id   } } @everything ],
        MediumFormat => [ map { $_->{format_id  } } @everything ],
        Release      => [ $self->_release_ids ],
    }
}

sub _build_re {
    my ($re, $loaded) = @_;
    return {
        release        => $re->{release_id} && $loaded->{Release}{ $re->{release_id} },
        country        => $re->{country_id} && $loaded->{Area}{ $re->{country_id} },
        label          => $re->{label_id}   && $loaded->{Label}{ $re->{label_id} },
        format         => $re->{format_id}  && $loaded->{MediumFormat}{ $re->{format_id} },
        label_id       => $re->{label_id},
        catalog_number => $re->{catalog_number},
        barcode        => $re->{barcode},
        date           => MusicBrainz::Server::Entity::PartialDate->new_from_row( $re->{date} )
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        additions => [ map { _build_re($_, $loaded) } $self->_additions ],
        removals  => [ map { _build_re($_, $loaded) } $self->_removals  ],
        edits => [
            map { +{
                release => $_->{release_id} && $loaded->{Release}{ $_->{release_id} },
                label   => {
                    old => $_->{old}{label_id} && $loaded->{Label}{ $_->{old}{label_id} },
                    new => $_->{new}{label_id} && $loaded->{Label}{ $_->{new}{label_id} },
                },
                label_id => {
                    old => $_->{old}{label_id},
                    new => $_->{new}{label_id}
                },
                date    => {
                    old => MusicBrainz::Server::Entity::PartialDate->new_from_row($_->{old}{date}),
                    new => MusicBrainz::Server::Entity::PartialDate->new_from_row($_->{new}{date})
                },
                country => {
                    old => $loaded->{Area}{ $_->{old}{country_id} },
                    new => $loaded->{Area}{ $_->{new}{country_id} },
                },
                format => {
                    old => $_->{old}{format_id} && $loaded->{MediumFormat}{ $_->{old}{format_id} },
                    new => $_->{new}{format_id} && $loaded->{MediumFormat}{ $_->{new}{format_id} },
                },
                barcode => {
                    old => $_->{old}{barcode},
                    new => $_->{new}{barcode},
                },
                catalog_number => {
                    old => $_->{old}{catalog_number},
                    new => $_->{new}{catalog_number},
                },
            } } $self->_edits
        ]
    }
}

sub upgrade_re
{
    my $self   = shift;
    my $event  = shift;
    my $prefix = shift || '';

    my %event  = map {
        # Some attributes are of the format "b=" which split would
        # return a single value for. This screws up the hash assignment
        # so this forces it to return a key AND value.
        my ($key, $value) = split /=/;
        ($key, $value)
    } split /\s+/, $event;

    return {
        release_id     => $self->resolve_release_id($event{"${prefix}id"}),
        date           => upgrade_date($event{"${prefix}d"}),
        country_id     => upgrade_id($event{"${prefix}c"}),
        label_id       => upgrade_id($event{"${prefix}l"}),
        catalog_number => _decode($event{"${prefix}n"}),
        barcode        => _decode($event{"${prefix}b"}),
        format_id      => upgrade_id($event{"${prefix}f"})
    };
}

sub upgrade
{
    my $self = shift;

    my @additions;
    for (my $i = 0; 1; $i++) {
        my $addition = $self->new_value->{"add$i"} or last;
        push @additions, $self->upgrade_re($addition);
    }

    my @removals;
    for (my $i = 0; 1; $i++) {
        my $removal = $self->new_value->{"remove$i"} or last;
        push @removals, $self->upgrade_re($removal);
    }

    my @edits;
    for (my $i = 0; 1; $i++) {
        my $edit = $self->new_value->{"edit$i"} or last;
        my $old  = $self->upgrade_re($edit);
        my $new  = $self->upgrade_re($edit, 'n');
        my $id   = delete $old->{release_id};
        delete $new->{release_id};

        push @edits, {
            release_id => $id,
            old        => $old,
            new        => $new
        };
    }

    $self->data({
        additions => \@additions,
        removals  => \@removals,
        edits     => \@edits,
    });

    return $self;
}

sub _decode
{
    my $t = $_[0];
    return undef if (!defined $t);
    $t =~ s/\$20/ /g;
    $t =~ s/\$3D/=/g;
    $t =~ s/\$26/\$/g;
    return $t;
}

1;
