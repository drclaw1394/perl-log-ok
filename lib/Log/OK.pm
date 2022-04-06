package Log::OK;

use strict;
use warnings;
use version; our $VERSION=version->declare("v0.1.0");
use feature "state";
use Carp qw<croak>;
use constant::more ();

use constant DEBUG_=>0;		#Heh...
use feature qw"say state";

my %systems=(
	"Log::Any"=>\&log_any,
	"Log::ger"=>\&log_ger,
	"Log::log4perl"=>\&log_log4perl,
	"Log::Dispatch"=>\&log_dispatch
);


use constant::more();
sub import {
	#arguments are lvl , opt, env, cat in hash ref
	my $p=shift;
	my $hr=shift;

	my $caller=caller;
	
	my $sub;
	if($hr->{sys}){
		#manual selection of logging system
		$sub=$systems{$hr->{sys}};
		croak "Unsupported logging system" unless $sub;
	}
	else{
		#attempt to auto detect the logging system
		$sub=auto_detect();
	}

	constant::more->import({
			logging=>{

				val=>$hr->{lvl},
				opt=>$hr->{opt},
				env=>$hr->{env},
				sys=>$hr->{sys},
				sub=>$sub,
			}
		});
};

sub auto_detect {
	#check for Log::Any first
	DEBUG_ and say "log any adapter ".keys %Log::Any::Adapter:: ;
	DEBUG_ and say "log ger :. ".%Log::ger::Output::;
	(%Log::Any::Adapter:: )and return \&log_any;
	(%Log::ger::Output::) and return \&log_ger;
	%Log::Dispatch:: and return \&log_dispatch;
	%Log::Log4perl:: and return \&log_log4perl;

	#otherwise fallback to log any
	\&log_any;
	#\&log_log4perl;	
}

sub log_any {
        DEBUG_ and say "setup for Log::Any";
        my ($opt, $value)=@_;
        state $acc;
        state %lookup= (

        EMERGENCY => 0,
        ALERT     => 1,
        CRITICAL  => 2,
        ERROR     => 3,
        WARNING   => 4,
        NOTICE    => 5,
        INFO      => 6,
        DEBUG     => 7,
        TRACE     => 8,
    );

        my $level=$lookup{uc $value}//int($value);

        DEBUG_ and say "Level input $value";
        DEBUG_ and say "Level output $level";

        $acc+=$level;

        #print "Calling sub for $caller \n";

        (
                #Contants to define
                "Log::OK::EMERGENCY"=>$level>=0,
                "Log::OK::ALERT"=>$level>=1,
                "Log::OK::CRITICAL"=>$level>=2,
                "Log::OK::ERROR"=>$level>=3,
                "Log::OK::WARN"=>$level>=4,
                "Log::OK::NOTICE"=>$level>=5,
                "Log::OK::INFO"=>$level>=6,
                "Log::OK::DEBUG"=>$level>=7,
                "Log::OK::TRACE"=>$level>=8,

                "Log::OK::LEVEL"=>$value
        )
}

sub log_ger {
	
	DEBUG_ and say "setup for Log::ger";
	my ($opt, $value)=@_;
	state $acc;
	state %lookup=(
		fatal   => 10,
		error   => 20,
		warn    => 30,
		info    => 40,
		debug   => 50,
		trace   => 60,
	);

    	my $level=$lookup{lc $value}//int($value);
	$acc+=$level;
	(
		#TODO: these values don't work well with 
		#incremental logging levels from the command line
		
		"Log::OK::FATAL"=>$level>=10,
		"Log::OK::ERROR"=>$level>=20,
		"Log::OK::WARN"=>$level>=30,
		"Log::OK::INFO"=>$level>=40,
		"Log::OK::DEBUG"=>$level>=50,
		"Log::OK::TRACE"=>$level>=60,

		"Log::OK::LEVEL"=>$value
	)

}

sub log_dispatch {
	DEBUG_ and say "setup for Log::Dispatch";
	my ($opt, $value)=@_;
	state $acc;
	state %lookup=(
		debug=>0,
		info=>1,
		notice=>2,
		warning=>3,
		error=>4,
		critical=>5,
		alert=>6,
		emergency=>7,

		#aliases
		warn=>3,
		err=>4,
		crit=>5,
		emerg=>7
	);

    	my $level=$lookup{lc $value}//int($value);


	$acc+=$level;

	(
		#TODO: these values don't work well with 
		#incremental logging levels from the command line

		"Log::OK::EMERGENCY"=>$level<=7,
		"Log::OK::ALERT"=>$level<=6,
		"Log::OK::CRITICAL"=>$level<=5,
		"Log::OK::ERROR"=>$level<=4,
		"Log::OK::WARN"=>$level<=3,
		"Log::OK::NOTICE"=>$level<=2,
		"Log::OK::INFO"=>$level<=1,
		"Log::OK::DEBUG"=>$level<=0,

		"Log::OK::LEVEL"=>$value
	)


}

sub log_log4perl {
	DEBUG_ and say "setup for Log::Log4perl";

	my ($opt, $value)=@_;
	state $acc;
	state %lookup=(

		ALL   => 0,
		TRACE =>  5000,
		DEBUG => 10000,
		INFO  => 20000,
		WARN  => 30000,
		ERROR => 40000,
		FATAL => 50000,
		OFF   => (2 ** 31) - 1
	);

	DEBUG_ and say "";
	DEBUG_ and say "VALUE: $value";

    	my $level=$lookup{uc $value}//int($value);

	DEBUG_ and say "LEVEL: $level";

	$acc+=$level;
	(
		#TODO: these values don't work well with 
		#incremental logging levels from the command line

		"Log::OK::OFF"=>$level<=$lookup{OFF},
		"Log::OK::FATAL"=>$level<=50000,
		"Log::OK::ERROR"=>$level<=40000,
		"Log::OK::WARN"=>$level<=30000,
		"Log::OK::INFO"=>$level<=20000,
		"Log::OK::DEBUG"=>$level<=10000,
		"Log::OK::TRACE"=>$level<=5000,
		"Log::OK::ALL"=>$level<=0,

		"Log::OK::LEVEL"=> $level
	)
}

1;
