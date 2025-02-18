package MusicBrainz::Server::Controller::Role::Filter;
use Moose::Role;
use namespace::autoclean;

=head2 process_filter

Utility function for dynamically loading the filter form.

=cut

sub process_filter
{
    my ($self, $c, $create_form) = @_;

    my %filter;
    unless (exists $c->req->params->{'filter.cancel'}) {
        my $cookie = $c->req->cookies->{filter};
        my $has_filter_params = grep { /^filter\./ } keys %{ $c->req->params };
        if ($has_filter_params || ($cookie && defined($cookie->value) && $cookie->value eq '1')) {
            my $filter_form = $create_form->();
            if ($c->form_submitted_and_valid($filter_form)) {
                for my $name ($filter_form->filter_field_names) {
                    my $value = $filter_form->field($name)->value;
                    if ($value) {
                        $filter{$name} = $value;
                    }

                }
                $c->res->cookies->{filter} = { value => '1', path => '/' };
            }
        }
    }
    else {
        $c->res->cookies->{filter} = { value => '', path => '/' };
    }

    return \%filter;
}

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
