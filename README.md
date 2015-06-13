# NAME

CPAN::Flatten - flatten cpan module requirements without install

# SYNOPSIS

    $ perl -Ilib script/flatten Moo
    -> Searching distribution for Moo, found Moo-2.000001
      -> Searching distribution for Module::Runtime, found Module-Runtime-0.014
        -> Searching distribution for Module::Build, found Module-Build-0.4214
      -> Searching distribution for Class::Method::Modifiers, found Class-Method-Modifiers-2.11
      -> Searching distribution for Devel::GlobalDestruction, found Devel-GlobalDestruction-0.13
        -> Searching distribution for Sub::Exporter::Progressive, found Sub-Exporter-Progressive-0.001011
      -> Searching distribution for Role::Tiny, found Role-Tiny-2.000001

    H/HA/HAARG/Moo-2.000001.tar.gz
      runtime_requires
        Z/ZE/ZEFRAM/Module-Runtime-0.014.tar.gz
        E/ET/ETHER/Class-Method-Modifiers-2.11.tar.gz
        H/HA/HAARG/Devel-GlobalDestruction-0.13.tar.gz
        H/HA/HAARG/Role-Tiny-2.000001.tar.gz
    Z/ZE/ZEFRAM/Module-Runtime-0.014.tar.gz
      configure_requires
        L/LE/LEONT/Module-Build-0.4214.tar.gz
      build_requires
        L/LE/LEONT/Module-Build-0.4214.tar.gz
    L/LE/LEONT/Module-Build-0.4214.tar.gz
    E/ET/ETHER/Class-Method-Modifiers-2.11.tar.gz
    H/HA/HAARG/Devel-GlobalDestruction-0.13.tar.gz
      runtime_requires
        F/FR/FREW/Sub-Exporter-Progressive-0.001011.tar.gz
    F/FR/FREW/Sub-Exporter-Progressive-0.001011.tar.gz
    H/HA/HAARG/Role-Tiny-2.000001.tar.gz

# DESCRIPTION

This is experimental.

CPAN::Flatten flattens cpan module requirements without install.

As you know, the cpan world allows cpan modules to configure themselves dynamically.
So actual requirements can not be determined
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
