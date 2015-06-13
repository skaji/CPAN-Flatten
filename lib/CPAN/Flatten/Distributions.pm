package CPAN::Flatten::Distributions;
use strict;
use warnings;
use CPAN::Flatten::Distribution;
use CPAN::Flatten::Distributions::Emitter;
use CPAN::Meta::YAML ();
use overload '@{}' => sub { shift->{distributions} };

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
    return 1 if $package eq "perl";
    for my $distribution (@$self) {
        return 1 if $distribution->providing($package, $version);
    }
    return;
}

sub without_core {
    my $self = shift;
    my $new = (ref $self)->new;
    shift @$new;
    $new->add($_) for grep !$_->is_core, @$self;
    $new;
}

sub emit {
    my $self = shift;
    CPAN::Flatten::Distributions::Emitter->emit($self->without_core);
}

1;
