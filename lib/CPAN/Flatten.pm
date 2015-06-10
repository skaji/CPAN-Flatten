package CPAN::Flatten;

use strict;
use 5.008_005;
our $VERSION = '0.01';

use CPAN::Flatten::Artifact::Factory;
use CPAN::Flatten::Artifacts;

sub new {
    my ($class, %opt) = @_;
    bless {%opt}, $class;
}
sub info {
    my ($self, $depth) = (shift, shift);
    warn "  " x $depth, "-> @_\n";
}

sub flatten {
    my ($self, $package, $version) = @_;
    my $artifacts = CPAN::Flatten::Artifacts->new;
    my $miss = +{};
    my $depth = 0;
    $self->_flatten($depth, $miss, $artifacts, $package, $version);
    wantarray ? ($artifacts, $miss) : $artifacts;
}

sub _flatten {
    my ($self, $depth, $miss, $artifacts, $package, $version) = @_;
    return if $miss->{$package};
    if (!$artifacts->providing($package, $version)) {
        $self->info($depth, "Searching artifact of $package");
        my ($artifact, $reason) = CPAN::Flatten::Artifact::Factory->from_pacakge($package, $version);
        if (!$artifact) {
            $miss->{$package}++;
            $self->info($depth, "Cannot find artifact for $package, $reason");
            return;
        }
        $artifacts->add($artifact);
        $depth++;
        for my $dependency (@{$artifact->dependencies}) {
            $self->_flatten($depth, $miss, $artifacts, $dependency->{package}, $dependency->{version});
        }
    }
    return;
}

1;
__END__

=encoding utf-8

=head1 NAME

CPAN::Flatten - flatten cpan module dependencies without install

=head1 SYNOPSIS

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

See L<https://gist.github.com/shoichikaji/d24d4c790057c62e23e5> for the whole output.

=head1 DESCRIPTION

This is an experimental.

CPAN::Flatten flattens cpan module dependencies without install.

As you know, the cpan world allows cpan modules to configure themselves dynamically.
So actual dependencies can not be detemined
unless you install them to your local machines.

But, I think dynamic configuration is generally harmful,
and we should avoid that.

So what happens if we flattens cpan module dependencies without install?

=head1 AUTHOR

Shoichi Kaji E<lt>skaji@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2015- Shoichi Kaji

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
