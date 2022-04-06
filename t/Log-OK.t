use strict;
use warnings;

use Test::More tests => 1;

use Log::OK {
	lvl=>8,
	opt=>"verbose=i",
};


trace_ok and print "trace ok\n";
warn_ok and print "warn ok\n";
error_ok and print "error ok\n";


