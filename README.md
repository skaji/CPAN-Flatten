# NAME

CPAN::Flatten - flatten cpan module dependencies without install

# SYNOPSIS

    $ perl -Ilib script/flatten Moose
    -> Searching artifact of Moose
      -> Searching artifact of Module::Runtime
        -> Searching artifact of Module::Build
      -> Searching artifact of Data::OptList
        -> Searching artifact of Params::Util
        -> Searching artifact of Sub::Install
      -> Searching artifact of Eval::Closure
        -> Searching artifact of Try::Tiny
    ...

See [https://gist.github.com/shoichikaji/d24d4c790057c62e23e5](https://gist.github.com/shoichikaji/d24d4c790057c62e23e5) for the whole output.

# DESCRIPTION

This is an experimental.

CPAN::Flatten flattens cpan module dependencies without install.

As you know, the cpan world allows cpan modules to configure themselves dynamically.
So actual dependencies can not be detemined
unless you install them to your local machines.

But, I think dynamic configuration is generally harmful,
and we should avoid that.

So what happens if we flattens cpan module dependencies without install?

# AUTHOR

Shoichi Kaji <skaji@cpan.org>

# COPYRIGHT

Copyright 2015- Shoichi Kaji

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
