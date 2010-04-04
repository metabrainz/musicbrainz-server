package MusicBrainz::Server::Data::Role::Subobject;
use MooseX::Role::Parameterized;
use MooseX::Types::Moose qw( Str );

parameter 'prefix' => (
    isa => Str,
);

role
{
    my $params = shift;
    my $prefix = $params->prefix;

    method load => sub
    {
        my ($self, @objs) = @_;
        @objs = grep { defined } @objs or return;

        my $attr_obj = $prefix || $self->table->name;
        my $attr_id = $attr_obj . "_id";
        @objs = grep { defined } @objs;
        my %ids = map {
            $_->meta->find_attribute_by_name($attr_id)->get_value($_) || ""=> 1
        } @objs;
        my @ids = grep { $_ } keys %ids;
        my $data;
        if (@ids) {
            $data = $self->get_by_ids(@ids);
            foreach my $obj (@objs) {
                my $id = $obj->meta->find_attribute_by_name($attr_id)
                    ->get_value($obj);
                if (defined $id && exists $data->{$id}) {
                    $obj->meta->find_attribute_by_name($attr_obj)
                        ->set_value($obj, $data->{$id});
                }
            }
        }
        return defined $data ? values %{$data} : ();
    };
};

1;

