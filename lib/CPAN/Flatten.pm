package CPAN::Flatten;

use strict;
use 5.008_005;
our $VERSION = '0.01';

use CPAN::Flatten::Distribution::Factory;
use CPAN::Flatten::Distributions;

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
    my $distributions = CPAN::Flatten::Distributions->new;
    my $miss = +{};
    my $depth = 0;
    $self->_flatten($depth, $miss, $distributions, $package, $version);
    wantarray ? ($distributions, $miss) : $distributions;
}

sub _flatten {
    my ($self, $depth, $miss, $distributions, $package, $version) = @_;
    return if $miss->{$package};
    if (!$distributions->providing($package, $version)) {
        $self->info_progress($depth, "Searching distribution for $package");
        my ($distribution, $reason) = CPAN::Flatten::Distribution::Factory->from_pacakge($package, $version);
        if ($distribution) {
            $self->info_done("found @{[$distribution->name]}");
        } else {
            $miss->{$package}++;
            $self->info_done($reason);
            return;
        }
        $distributions->add($distribution);
        $depth++;
        for my $requirement (@{$distribution->requirements}) {
            $self->_flatten($depth, $miss, $distributions, $requirement->{package}, $requirement->{version});
        }
    }
    return;
}

1;
__END__

=encoding utf-8

=head1 NAME

CPAN::Flatten - flatten cpan module requirements without install

=head1 SYNOPSIS

  $ perl -Ilib script/flatten Moose
  -> Searching distribution for Moose, found Moose-2.1405
    -> Searching distribution for Module::Runtime, found Module-Runtime-0.014
      -> Searching distribution for Module::Build, found Module-Build-0.4214
    -> Searching distribution for Data::OptList, found Data-OptList-0.109
      -> Searching distribution for Params::Util, found Params-Util-1.07
      -> Searching distribution for Sub::Install, found Sub-Install-0.928
    -> Searching distribution for Eval::Closure, found Eval-Closure-0.13
  ...

See L<https://gist.github.com/shoichikaji/d24d4c790057c62e23e5> for the whole output.

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

Shoichi Kaji E<lt>skaji@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2015- Shoichi Kaji

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
