use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	      'NAME'	=> 'Tie::IP::Address',
	      'VERSION_FROM' => 'Address.pm', # finds $VERSION
	      'LIBS'	=> [''],   # e.g., '-lm' 
	      'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
	      'INC'	=> '',     # e.g., '-I/usr/include/other' 
	      'PREREQ_PM' => {
		  'IP::Address' => 0,
		  'Carp' => 0
		  }
);
