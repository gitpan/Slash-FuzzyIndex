use ExtUtils::MakeMaker;

WriteMakefile(
    AUTHOR              => 'Kang-min Liu (gugod@gugod.org)',
    ABSTRACT		=> "FuzzyIndex Search Engine using slash as frontend.",
    'NAME'	=> 'Slash::FuzzyIndex',
    'VERSION_FROM' => 'lib/Slash/FuzzyIndex.pm', # finds $VERSION
    'PM'	=> { 'lib/Slash/FuzzyIndex.pm' => '$(INST_LIBDIR)/FuzzyIndex.pm' },
);


