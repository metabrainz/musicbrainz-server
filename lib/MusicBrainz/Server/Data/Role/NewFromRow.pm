package MusicBrainz::Server::Data::Role::NewFromRow;
use Moose::Role;
use Class::Load qw( load_class );
use namespace::autoclean;

sub _entity_class
{
    die('Not implemented');
}

sub _column_mapping
{
    return {};
}

sub _new_from_row
{
    my ($self, $row, $prefix) = @_;
    return unless $row;
    my %info;
    my %mapping = %{$self->_column_mapping};
    my @attribs = %mapping ? keys %mapping : keys %{$row};
    $prefix ||= '';
    foreach my $attrib (@attribs) {
        my $column = $mapping{$attrib} || $attrib;
        my $val;
        if (ref($column) eq 'CODE') {
            $val = $column->($row, $prefix);
        }
        elsif (defined $row->{$prefix.$column}) {
            $val = $row->{$prefix.$column};
        }
        $info{$attrib} = $val if defined $val;
    }
    my $entity_class = $self->_entity_class($row);
    load_class($entity_class);
    return $entity_class->new(%info);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
