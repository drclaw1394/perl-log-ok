use strict;
use warnings;

use feature "say";

use Log::Dispatch;

use Log::OK {
	lvl=>"alert",
	opt=>"verbose=s"
};

$GLOBAL::logger=Log::Dispatch->new(
	outputs=>[
		["Screen", min_level=>Log::OK::LEVEL]
	]
);


my $dir;
BEGIN {
	my @seg=split "/", __FILE__;
	pop @seg;
	$dir=join "/", @seg;
}

use lib $dir;


use My_Module;

My_Module::do_module_stuff();
