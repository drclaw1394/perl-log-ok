# NAME

Log::OK -  Disable inactive logging statements from the command line

# SYNOPSIS

## Application

Setup your adaptor/dispatchers/output like usual using
your logging framework. (1)

Then `use Log::OK`  to setup a default logging level and specify a command
line option (or environment variable) to set logging level. (2)

Optionally synchronise the logging level of your logger to that configured by `Log::OK` :

```perl
    use strict;
    use warnings;

    use Log::Any::Adaptor;                  #(1)
    Log::Any::Adaptor->set("Log4perl");


    use Log::OK {                           #(2)
            lvl=>"info",
            opt=>"verbose"
    };

    My_Module::do_module_stuff();


    
```

## Module

In your module, bring in your logging framework (Log::Any  and Log::Log4perl
shown). (1)

Then bring in `Log::OK`, and optionally configure it with a default
level. This will be used if the  top level script didn't define one (2)

Constant names will be logging levels supported in your logging module, but
converted to upper case. Use a constant together with a logical "and" and your
logging statement for perl to optimise away inactive levels. (3)

```perl
    package My_Module;
    use strict;
    use warnings;

    use Log::Any qw($log);  #(1)

    use Log::OK;            #(2)



    sub do_module_stuff {
                            #(3)

            Log::OK::EMERGENCY and $log->emergency("Emergency");
            Log::OK::ALERT and $log->alert("Alert");
            Log::OK::CRITICAL and $log->emergency("Critical");
            Log::OK::ERROR and $log->emergency("Error");
            Log::OK::WARN and $log->emergency("Warning");
            Log::OK::NOTICE and $log->emergency("Notice");
            Log::OK::INFO and $log->emergency("Info");
            Log::OK::TRACE and $log->emergency("Trace");
    }

    1;
```

## Run the program

The logging level and compile time constants are configured via the command
line using the [GetOpt::Long](https://metacpan.org/pod/GetOpt%3A%3ALong) options specification used:

```perl
    perl my_app.pl --verbose error
```

The output of the above  program/module/log level would be

```
    Emergency
    Alert
    Critical
    Error
    Warn
```

Notice, Info and Trace will not be executed at runtime

# DESCRIPTION

[Log::OK](https://metacpan.org/pod/Log%3A%3AOK) creates compile time constants/flags for each level of logging
supported in your selected logging framework.  This module does not implement
logging features.

If your selected logging system was [Log::ger](https://metacpan.org/pod/Log%3A%3Ager), and the logging level was set to "info"
for example, the constants generated would be:

```
    Log::OK::FATAL  = 1;
    Log::OK::ERROR  = 1;
    Log::OK::WARN   = 1;
    Log::OK::INFO   = 1;
    Log::OK::DEBUG  = undef;
    Log::OK::TRACE  = undef;
```

The value of constants are determined from the logging level specified in code,
from the command line (set or increment) or an environment variable of your
choosing.

The idea is to have an logger independent method of completely disabling inactive
logging statements to improve program performance. 

By using the generated constants/flags in the following fashion, perl will
optimise away this entire statement when `Log::OK::DEBUG` is false for example:

```
            Log::OK::DEBUG and $log->emergency("Emergency");
```

## Supported Logging Modules 

The logging modules supported are [Log::Any](https://metacpan.org/pod/Log%3A%3AAny), [Log::ger](https://metacpan.org/pod/Log%3A%3Ager), [Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch)
and [Log::Log4perl](https://metacpan.org/pod/Log%3A%3ALog4perl). These systems can be autodetected if they are imported
before [Log::OK](https://metacpan.org/pod/Log%3A%3AOK). The constants generated are named according to the detected
modules logging levels.

# USAGE

The constants generated are determined by the logging system selected/detected
at the point of the `use Log::OK` pragma.

```perl
    use Log::OK {
            opt=>$get_opt_long_spec,
            env=>$env_var_name,
            lvl=>$defualt_level,
            sys=>$logging_system,
            
    };
```

The pragma takes a single hash ref argument:

## Hash keys

All keys to the hash are optional and are detailed below:

### lvl

This is the base logging level. It may be modified by a command line option,
or environment variable.  It must be a string representing a logging level of
your chosen logging framework.

If the field is not supplied, then the lowest logging level is set as the
default.

### opt

Represents a [GetOpt::Long](https://metacpan.org/pod/GetOpt%3A%3ALong) option name to use in processing the command line
options.  It has a `":s"` appended to it to allow [GetOpt::Long](https://metacpan.org/pod/GetOpt%3A%3ALong) to
process just a switch or a switch with a value.

For example if `opt=\gt"verbose=s"`, the logging level will be set to "debug"
with the following:

```perl
            perl my_app.pl --verbose debug

                    #or

            perl my_app.pl --v debug
```

If the switch only is used, each use will increment the logging level:

```perl
            #Increments the logging two levels above the default
            perl my_app.pl -v -v

            #Set the logging level to info and then increase to the next level
            #perl my_app.pl -v info -v
```

If a invalid level is specified on the command line, a list of valid options is
printed with a croak call

### env

The name of the environment variable to use to set the logging level. For
example setting to `env=\gt"MY_VAR"`  the logging level could be set to
"trace" with:

```perl
            MY_VAR=trace perl my_app.pl

    
```

### sys

This informs `Log::OK` of the logging system in use, instead of an attempt to
detect it automatically.  It is a string value of the package name of the
logging system. For example to force constants that relate to `Log::ger`:

```perl
            sys=>"Log::ger"
```

## Constant Naming 

The names of the constants generated are specific to the logging system used
and are installed in the `Log::OK` namespace; The names are the same as the
logging levels, but are converted to uppercase in the normal constant style. If
the logging system has aliases to levels these are also used to generate
constants

## Import and Constant Definition Precedence 

For autodetection to work, the logging framework (producer or consumer) should
be imported before `Log::OK`

```perl
    use Log::Any;
    #configure log any

    use Log::OK {...}
```

Constants are only defined once in a first come first serve basis. So this
means to override the logging levels of a required module, `use Log::OK` will
need to appear before any modules that also use it:

```perl
    use Log::OK {..}

    use My::Fancy::Module;
```

## Extraciting log level

The log level used to create the constants is accessible via `Log::OK::LEVEL`.
It is a string representation of the log level in the detected logging
framework.

As `Log::OK` doesn't interfere with your logging setup, use this value to set
the logging level in your logger:

```
    #Log::Log4perl 
    $logger->level(Log::OK::LEVEL);
```

The other way is to process command line options in your script. `Log::OK`
does not consume the `@ARGV` when processing command line arguments.

## Error Reporting

If the logging level attempting to be set is not supported by the logging
system detected, croak is called with a list of supported level names

When used in logical combination with a logging statement, it can completely
remove the runtime overhead when the current logging level would not generate
output.

```
    Log::OK::ERROR and log_error(...);      #This will execute

    Log::OK::DEBUG and log_debug(...);      #This is optimised away 
                                            #and has no runtime overhead
```

The constants generated are used in a logical "and" statement with your
logging call:

```
    Log::OK::DEBUG and $log->debug(...); #Log::Any;

    Log::OK::TRACE and log_trace(...); #Log::ger;
```

If the constant is true, the remainder of the statement will execute; If the
constant is false, the statement will be optimised away at compile time,
resulting in no runtime overhead.

# AUTHOR

Ruben Westerberg, <drclaw@mac.com>

# COPYRIGHT AND LICENSE

Copyright (C) 2022 by Ruben Westerberg

Licensed under MIT

# DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE.