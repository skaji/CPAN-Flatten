package CPAN::Flatten::Distributions;
use strict;
use warnings;
use CPAN::Flatten::Distribution;
use CPAN::Flatten::Distributions::Emitter;
use CPAN::Meta::YAML ();
use overload '@{}' => sub { shift->{distributions} }, fallback => 1;

sub new {
    my ($class, %opt) = @_;
    bless {%opt, distributions => [CPAN::Flatten::Distribution->core]}, $class;
}

sub add {
    my ($self, $distribution) = @_;
    push @$self, $distribution;
}

sub providing {
    my ($self, $package, $version) = @_;
    $self->providing_distribution($package, $version) ? 1 : 0;
}

sub emit {
    my ($self, $fh) = @_;
    CPAN::Flatten::Distributions::Emitter->emit($self, $fh);
}

sub providing_distribution {
    my ($self, $package, $version) = @_;
    if ($package eq "perl") {
        my ($core) = grep $_->is_core, @$self;
        return $core;
    }
    for my $distribution (@$self) {
        return $distribution if $distribution->providing($package, $version);
    }
    return;
}

1;
