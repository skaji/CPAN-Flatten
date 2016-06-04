package CPAN::Flatten;

use strict;
use 5.008_005;
our $VERSION = '0.01';

use CPAN::Flatten::Distribution::Factory;
use CPAN::Flatten::Distribution;

sub new {
    my ($class, %opt) = @_;
    bless {%opt}, $class;
}

sub info_progress {
    my ($self, $depth) = (shift, shift);
    print STDERR "  " x $depth, "-> @_";
}
sub info_done {
    shift;
    print STDERR ", @_\n";
}

sub flatten {
    my ($self, $package, $version) = @_;
    my $distribution = CPAN::Flatten::Distribution->new;
    my $miss = +{};
    $self->_flatten($distribution, $miss, $package, $version);
    wantarray ? ($distribution, $miss) : $distribution;
}

sub _flatten {
    my ($self, $distribution, $miss, $package, $version) = @_;
    return 0 if $miss->{$package};
    return 0 if CPAN::Flatten::Distribution->is_core($package, $version);
    my $already = $distribution->root->providing($package, $version);
    if ($already) {
        return 0 if $distribution->is_child($already);
        $distribution->add_child( $already->dummy );
        return 1;
    }

    $self->info_progress($distribution->depth, "Searching distribution for $package");
    my ($found, $reason) = CPAN::Flatten::Distribution::Factory->from_pacakge($package, $version);
    if (!$found) {
        $miss->{$package}++;
        $self->info_done($reason);
        return 0;
    }
    $self->info_done("found @{[$found->name]}");
    $distribution->add_child($found);
    my $count = 0;
    for my $requirement (@{$found->requirements}) {
        $count += $self->_flatten($found, $miss, $requirement->{package}, $requirement->{version});
    }
    return $count; # count == 0 means leaf
}

1;
__END__

=encoding utf-8

=head1 NAME

CPAN::Flatten - flatten cpan module requirements without install

=head1 SYNOPSIS

  $ perl -Ilib script/flatten Moo
  -> Searching distribution for Moo, found HAARG/Moo-2.000001
    -> Searching distribution for Class::Method::Modifiers, found ETHER/Class-Method-Modifiers-2.11
    -> Searching distribution for Devel::GlobalDestruction, found HAARG/Devel-GlobalDestruction-0.13
      -> Searching distribution for Sub::Exporter::Progressive, found FREW/Sub-Exporter-Progressive-0.001011
    -> Searching distribution for Module::Runtime, found ZEFRAM/Module-Runtime-0.014
      -> Searching distribution for Module::Build, found LEONT/Module-Build-0.4214
    -> Searching distribution for Role::Tiny, found HAARG/Role-Tiny-2.000001

  H/HA/HAARG/Moo-2.000001.tar.gz
    E/ET/ETHER/Class-Method-Modifiers-2.11.tar.gz
    H/HA/HAARG/Devel-GlobalDestruction-0.13.tar.gz
    Z/ZE/ZEFRAM/Module-Runtime-0.014.tar.gz
    H/HA/HAARG/Role-Tiny-2.000001.tar.gz
  E/ET/ETHER/Class-Method-Modifiers-2.11.tar.gz (leaf)
  H/HA/HAARG/Devel-GlobalDestruction-0.13.tar.gz
    F/FR/FREW/Sub-Exporter-Progressive-0.001011.tar.gz
  F/FR/FREW/Sub-Exporter-Progressive-0.001011.tar.gz (leaf)
  Z/ZE/ZEFRAM/Module-Runtime-0.014.tar.gz
    L/LE/LEONT/Module-Build-0.4214.tar.gz
  L/LE/LEONT/Module-Build-0.4214.tar.gz (leaf)
  H/HA/HAARG/Role-Tiny-2.000001.tar.gz (leaf)

=head1 DESCRIPTION

This is experimental.

CPAN::Flatten flattens cpan module requirements without install.

As you know, the cpan world allows cpan modules to configure themselves dynamically.
So actual requirements can not be determined
unless you install them to your local machines.

But, I think dynamic configuration is generally harmful,
and we should avoid that.

So what happens if we flattens cpan module requirements without install?

=head1 AUTHOR

Shoichi Kaji <skaji@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Shoichi Kaji <skaji@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
