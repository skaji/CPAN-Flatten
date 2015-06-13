# NAME

CPAN::Flatten - flatten cpan module requirements without install

# SYNOPSIS

    $ perl -Ilib script/flatten Moose
    -> Searching distribution for Moose, found Moose-2.1405
      -> Searching distribution for Module::Runtime, found Module-Runtime-0.014
        -> Searching distribution for Module::Build, found Module-Build-0.4214
      -> Searching distribution for Data::OptList, found Data-OptList-0.109
        -> Searching distribution for Params::Util, found Params-Util-1.07
        -> Searching distribution for Sub::Install, found Sub-Install-0.928
      -> Searching distribution for Eval::Closure, found Eval-Closure-0.13
    ...

See [https://gist.github.com/shoichikaji/d24d4c790057c62e23e5](https://gist.github.com/shoichikaji/d24d4c790057c62e23e5) for the whole output.

# DESCRIPTION

This is experimental.

CPAN::Flatten flattens cpan module requirements without install.

As you know, the cpan world allows cpan modules to configure themselves dynamically.
So actual requirements can not be detemined
unless you install them to your local machines.

But, I think dynamic configuration is generally harmful,
and we should avoid that.

So what happens if we flattens cpan module requirements without install?

# AUTHOR

Shoichi Kaji <skaji@cpan.org>

# COPYRIGHT

Copyright 2015- Shoichi Kaji

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
