package CPAN::Flatten::Artifacts;
use strict;
use warnings;
use CPAN::Flatten::Artifact;
use overload '@{}' => sub { shift->{artifacts} };

sub new {
    my ($class, %opt) = @_;
    bless {%opt, artifacts => [CPAN::Flatten::Artifact->core]}, $class;
}

sub add {
    my ($self, $artifact) = @_;
    push @{$self->{artifacts}}, $artifact;
}

sub providing {
    my ($self, $package, $version) = @_;
    if ($package eq "perl") {
        return 1;
    }
    for my $artifact (@{$self->{artifacts}}) {
        return 1 if $artifact->providing($package, $version);
    }
    return;
}

1;
