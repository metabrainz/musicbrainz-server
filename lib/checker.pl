use File::Find::Rule;
use UNIVERSAL::require;

use Moderation;
use ModDefs;

use Data::Dumper;
print "Type is " . Moderation->get_registered_class('MOD_ADD_ARTIST')->moderation_id;
