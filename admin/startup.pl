  use strict;
  
  # make sure we are in a sane environment.
  $ENV{GATEWAY_INTERFACE} =~ /^CGI-Perl/ or die "GATEWAY_INTERFACE not Perl!";
   
  # for things in the "/perl" URL
  use Apache::Registry;          
  use Apache::Session;          
   
  #load perl modules of your choice here
  #this code is interpreted *once* when the server starts
  use DBI;
  use DBD::mysql;
  
  sub UNIVERSAL::AUTOLOAD
  { 
      my $class = shift;

      warn "$class can't $UNIVERSAL::AUTOLOAD\n" unless $UNIVERSAL::AUTOLOAD =~ 
           /DESTROY$/
  }

  return 1;
