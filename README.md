# NAME

Log::OK -  Disable inactive logging statements from the command line

# SYNOPSIS

## Application

Choose your logging framework ([Log::ger](https://metacpan.org/pod/Log%3A%3Ager) shown). (1)

Setup your adaptor/dispatchers/output like usual (2)

Then `use Log::OK`  to setup a default logging level and/or specify a command
line option (or environment variable) to set logging level. (3)

```perl
# Top level application
      use Log::ger;                                 #(1)
      use Log::ger::Output "Screen";  #(2)

      use Log::OK {                                 #(3)
              lvl=>"info",            
              opt=>"verbose"          
      };


      My_Module::do_module_stuff();
```

## Module

In your module, bring in your logging framework ([Log::ger](https://metacpan.org/pod/Log%3A%3Ager) shown). (1)

Then bring in `Log::OK`, and optionally configure it with a default level.
This will be used if the  top level script didn't define one (2)

Constant names will be logging levels supported in your logging module, but
converted to upper case.

Use a constant together with a logical "and" and your
logging statement for perl to optimise away inactive levels. (3)

```perl
# Module ...
      package My_Module;

      use Log::ger;   #(1)
      use Log::OK;    #(2)

      sub do_module_stuff {
                              #(3)

              Log::OK::FATAL and log_fatal("Fatal");
              Log::OK::ERROR and log_error("Error");
              Log::OK::WARN and log_warn("Warning");
              Log::OK::INFO and log_info("Information");
              Log::OK::DEBUG and log_debug("Debug");
              Log::OK::TRACE and log_trace("Trace");
      }

      1;
```

## Run the program

The logging level and compile time constants are configured via the command
line using the [GetOpt::Long](https://metacpan.org/pod/GetOpt%3A%3ALong) options specification used:

```perl
    perl my_app.pl --verbose error
```

The output of the above would be

```
    Fatal
    Error
    Warning
    Information
```

Notice, Debug and Trace logging  will not be executed at runtime

# DESCRIPTION

[Log::OK](https://metacpan.org/pod/Log%3A%3AOK) creates compile time constants/flags for each level of logging
supported by your selected logging framework.  This module does not implement
logging features, nor does it depend on any particular logger. It only
generates constants to help enable/disable logging efficiently.

The logging modules supported are [Log::Any](https://metacpan.org/pod/Log%3A%3AAny), [Log::ger](https://metacpan.org/pod/Log%3A%3Ager), [Log::Dispatch](https://metacpan.org/pod/Log%3A%3ADispatch)
and [Log::Log4perl](https://metacpan.org/pod/Log%3A%3ALog4perl). These systems can be autodetected if they are imported
before [Log::OK](https://metacpan.org/pod/Log%3A%3AOK). The constants generated are named according to the detected
modules logging levels.

For example, if your selected logging system was [Log::ger](https://metacpan.org/pod/Log%3A%3Ager), and the logging
level was set to "info", the constants generated would be:

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

The idea is to have a logger independent method of completely disabling inactive
logging statements to reduce runtime overhead.

By using the generated constants/flags in the following fashion, perl will
optimise away this entire statement when `Log::OK::DEBUG` is false for example:

```
            Log::OK::DEBUG and log_DEBUG("This message is optimised away");
```

# USAGE

The constants generated are determined by the logging system selected/detected
at the point of the `use Log::OK` pragma. That means you need to bring in your
logging framework before you bring in `Log::OK`:

```perl
use Log::Any;           # <- Pick one
use Log::ger;           # <-  
use Log::Dispatch;      # <-
use Log::Log4perl;      # <-

      use Log::OK {
              opt=>$get_opt_long_spec,
              env=>$env_var_name,
              lvl=>$defualt_level,
              sys=>$logging_system,
      };
```

## Hash keys

All keys to the hash are optional and are detailed below:

### lvl

This is the base logging level. It may be modified by a command line option, or
environment variable.  It must be a string representing a logging level in your
chosen logging framework.

If this field is not supplied, then the lowest logging level in your selected
logging module is set as the default (i.e Emergency, Trace...)

### opt

Represents a [GetOpt::Long](https://metacpan.org/pod/GetOpt%3A%3ALong) option name to use in processing the command line
options.  It has a `":s"` appended to it to allow [GetOpt::Long](https://metacpan.org/pod/GetOpt%3A%3ALong) to process
just a switch or a switch with a value.

**From v0.2.0:** If not specified it defaults to `"verbose"`. If you want no
command line options procssing, explicitly set to `undef`.

For example if `opt=>'verbose'`, (the default) the logging level will be
set to "debug" with the following:

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
            perl my_app.pl -v info -v
```

If a invalid level is specified on the command line, a list of valid options is
printed with a croak call

This is implemented using  [constant::more](https://metacpan.org/pod/constant%3A%3Amore). Please refer to that module for
more implementation details.

### env

The name of the environment variable to use to set the logging level. For
example setting to `env=>'MY_VAR'`  the logging level could be set to
"trace" with:

```perl
            MY_VAR=trace perl my_app.pl
```

This is implemented using  [constant::more](https://metacpan.org/pod/constant%3A%3Amore). Please refer to that module for
more implementation details.

### sys

This informs `Log::OK` of the logging system in use instead of an attempting
to detect it automatically.  It is a string value of the package name of the
logging system. For example to force constants that relate to `Log::ger`:

```perl
            sys=>"Log::ger"
```

## Constant Naming 

The names of the constants generated are specific to the logging system used
and are installed in the `Log::OK` namespace. The names are the same as the
logging levels, but are converted to uppercase the usual constant style. If
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

    use My::Fancy::Module; #module that uses Log::OK
```

## Extracting Log Level

The log level used to create the constants is accessible via `Log::OK::LEVEL`.
It is a string representation of the log level in the detected logging
framework.

**v0.1.4 and later**
If [Log::ger](https://metacpan.org/pod/Log%3A%3Ager) is used, it has the log level synchronised automatically with:

```
  Log::ger::Util::set_level Log::OK::LEVEL;
```

**Prior to v0.1.4**
As `Log::OK` doesn't interfere with your logging setup. As such, if you would
like to synchronise the levels in `Log::OK` and your logger, it will need to
be set manually in your logger:

```
      #Log::Log4perl
      $logger->level(Log::OK::LEVEL);

#Log:ger
Log::ger::Util::set_level Log::OK::LEVEL;
```

This is sometimes necessary to avoid internal filtering of the log messages

## Error Reporting

If the logging level attempting to be set is not supported by the logging
system detected, croak is called with a list of supported level names

# LIMITATIONS

Constants are treated as constants so, once they are defined, the value remains
the same for the program duration.

Using multiple logging frameworks in the same project (sub modules choosing
a different one that you for example) should work as long as:

- You don't need to rely on `Log::OK::LEVEL` to synchronise the logging level.
This value is framework specific.
- Command line processing is only done by one module.

Also the incremental changing of the logging level from the command line only
increases the logging level (no decrement).

Synchronising the logging level of your logging framework is easy in some and
not so easy in others. If you are missing log messages the logger might be
configured with a different logging level

# REPOSITOTY and BUGS

Please report and feature requests or bugs via the github repo:

[https://github.com/drclaw1394/perl-log-ok.git](https://github.com/drclaw1394/perl-log-ok.git)

# AUTHOR

Ruben Westerberg, <drclaw@mac.com>

# COPYRIGHT AND LICENSE

Copyright (C) 2023 by Ruben Westerberg

Licensed under MIT

# DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE.
