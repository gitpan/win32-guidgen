package Win32::Guidgen;

#require 5.005_62;
require Win32::API;

use strict;
use warnings;

use Carp;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Win32::Guidgen ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
create
);
our $VERSION = '0.02';

# Preloaded methods go here.
sub create {
	#
	# defintion of GUID structure
	#
	# typedef struct _GUID {
	#	DWORD	data1;
	#	WORD	data2;
	#	WORD	data3;
	#	BYTE	data4[8];
	# } GUID;
	#
	my $p_guid = pack("LIIC8", 0,0,0,0);

	my $CoCreateGuid = new Win32::API("ole32.dll", "CoCreateGuid", ["P"], "N");

	die "Could not create CoCreateGuid API call variable: $!\n" unless defined $CoCreateGuid;

	my $rc1 = $CoCreateGuid->Call($p_guid);
	
	# CoCreateGuid returns 0 on success
	if (! $rc1 ) {
		my $p_guidstr = pack("S39", 0);
		my $StringFromGuid = new Win32::API("ole32.dll", "StringFromGUID2", ["P", "P", "N"], "N");
		die "Could not create StringFromGuid API call variable: $!\n" unless defined $StringFromGuid;
		
		my $rc2 = $StringFromGuid->Call($p_guid, $p_guidstr, 39);
		
		if ($rc2) {
			my @chars = unpack("S$rc2", $p_guidstr);
			my $guid;
			foreach my $char (@chars) {
				$guid .= chr($char) unless $char == 0;
			}
			return $guid;
		}
	}

}

1;
__END__

=head1 NAME

Win32::Guidgen - Perl extension that generates GUID strings.

=head1 SYNOPSIS

	use strict;
	use Win32::Guidgen;

	my $guid = Win32::Guidgen::create();
	print "New GUID is $guid\n";

=head1 DESCRIPTION

Win32::Guidgen generate Generates Globally Unique Identifiers (B<GUIDs>).

Its one method, C<create()>, returns a string formatted like the following sample:

{c200e360-38c5-11ce-ae62-08002b2b79ef} 

where the successive fields break the B<GUID> into the form C<DWORD>-C<WORD>-C<WORD>-C<WORD>-C<WORD>.C<DWORD> covering the 128-bit B<GUID>. 
The string includes enclosing braces, which are an OLE convention.

=head2 EXPORT

None by default.

=head1 INSTALLATION

You install C<VCS::StarTeam>, as you would install any perl module library,
by running these commands:

	perl Makefile.PL
	make
	make test
	make install


=head1 AUTHOR

C<Win32::Guidgen> was written by Joe P. Hayes I<E<lt>jhayes@juicesoftware.comE<gt>> in 2001.

=head1 LICENSE

The C<Win32::Guidgen> module is Copyright (c) 2001 Joe P. Hayes.
All Rights Reserved.

You may distribute under the terms of either the GNU General Public License or the
Artistic License, as specified in the Perl README file.

=head1 SUPPORT / WARRANTY

The C<Win32::Guidgen> module is free software.

B<IT COMES WITHOUT WARRANTY OF ANY KIND.>

Commercial support for Perl can be arranged via The Perl Clinic.
For more details visit:

  http://www.perlclinic.com

=cut
