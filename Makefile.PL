use ExtUtils::MakeMaker;

WriteMakefile
(
 AUTHOR              => 'Kang-min Liu (gugod@gugod.org)',
 ABSTRACT            => 'A web search plugin for slash.',
 DISTNAME            => 'Slash-FuzzyIndex',
 PREREQ_PM           => {
     'OurNet::FuzzyIndex' => '0',
     'Slash'         => '0',
 },
 'NAME'	=> 'Slash::FuzzyIndex',
 'VERSION_FROM' => 'lib/Slash/FuzzyIndex.pm', # finds $VERSION
 'PM'	=> { 'lib/Slash/FuzzyIndex.pm' => '$(INST_LIBDIR)/FuzzyIndex.pm' },
 dist                => {
     COMPRESS        => 'gzip -9',
     SUFFIX          => '.gz',
 },
 );

