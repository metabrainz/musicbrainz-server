package MusicBrainz::Server::Form::DataQuality;

use strict;
use warnings;

use Moderation;

use base 'MusicBrainz::Server::Form';

=head1 NAME

MusicBrainz::Server::Form::DataQuality

=head1 DESCRIPTION

Provide an interface for changing the data quality of an entity

=head1 METHODS

=head2 name

Returns the name of this form

=cut

sub name { 'data-quality' }

=head2 profile

Returns a list of required and optional fields to change data quality

=cut

sub profile
{
    shift->with_mod_fields({
        required => {
            quality => {
                type             => 'Select',
                auto_widget_size => 3, # Force radio buttons, select_widget wasn't working
            }
        },
    });
}

sub options_quality
{
    [ ModDefs::QUALITY_LOW,    "Low",
      ModDefs::QUALITY_NORMAL, "Default",
      ModDefs::QUALITY_HIGH,   "High" ];
}

=head2 init_value

Initialize the value for form fields

=cut

sub init_value
{
    my ($self, $field, $item) = @_;
    $item ||= $self->item;

    return unless defined $item;

    use Switch;
    switch ($field->name)
    {
        case ('quality')
        {
            use ModDefs;

            return $item->quality == ModDefs::QUALITY_UNKNOWN ? ModDefs::QUALITY_UNKNOWN_MAPPED
                   :                                            $item->quality;
        }
    }
}

sub change_quality
{
    my $self = shift;
    my $controller = shift;

    $controller->change_quality($self->item, $self->value('quality'),
        $self->value('edit_note'));
}

=head1 LICENSE

This software is provided "as is", without warranty of any kind, express or
implied, including  but not limited  to the warranties of  merchantability,
fitness for a particular purpose and noninfringement. In no event shall the
authors or  copyright  holders be  liable for any claim,  damages or  other
liability, whether  in an  action of  contract, tort  or otherwise, arising
from,  out of  or in  connection with  the software or  the  use  or  other
dealings in the software.

GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt
Permits anyone the right to use and modify the software without limitations
as long as proper  credits are given  and the original  and modified source
code are included. Requires  that the final product, software derivate from
the original  source or any  software  utilizing a GPL  component, such  as
this, is also licensed under the GPL license.

=cut

1;
