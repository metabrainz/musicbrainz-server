package MusicBrainz::Server::Form::Field::Relationship;
use strict;
use warnings;


use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Compound';

has_field 'relationship_id' => (
    type => 'Integer',
    required_when => { removed => 1 },
);

has_field 'link_type_id' => (
    type => 'Integer',
);

has_field 'text' => (
    type => '+MusicBrainz::Server::Form::Field::URL',
);

has_field 'target' => (
    type => '+MusicBrainz::Server::Form::Field::GID',
);

has_field 'entity0_credit' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
);

has_field 'entity1_credit' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
);

has_field 'attributes' => (
    type => 'Repeatable',
);

has_field 'attributes.type' => (
    type => 'Compound',
);

has_field 'attributes.type.gid' => (
    type => '+MusicBrainz::Server::Form::Field::GID',
);

has_field 'attributes.credited_as' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
);

has_field 'attributes.text_value' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
);

has_field 'attributes.removed' => (
    type => 'Boolean',
);

has_field 'link_order' => (
    type => 'Integer',
);

has_field 'period' => (
    type => '+MusicBrainz::Server::Form::Field::DatePeriod',
    not_nullable => 1,
);

has_field 'backward' => (
    type => 'Boolean',
    default => 0,
);

has_field 'removed' => (
    type => 'Boolean',
    default => 0,
);

sub is_empty {
    my ($self) = @_;

    my $value = $self->value;
    return 1 unless (
        $value->{link_type_id} ||
        $value->{text} ||
        $value->{target} ||
        $value->{relationship_id}
    );
    return 0;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
