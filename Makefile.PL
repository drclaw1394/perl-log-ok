use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'Log::OK',
    VERSION_FROM      => 'lib/Log/OK.pm',
    PREREQ_PM         => {
	    "constant::more"=>0
    }, 
    ABSTRACT_FROM     => 'lib/Log/OK.pod', # retrieve abstract from module
    AUTHOR            => 'Ruben Westerberg <drclaw@mac.com>',
    LICENSE           => 'mit',
);
