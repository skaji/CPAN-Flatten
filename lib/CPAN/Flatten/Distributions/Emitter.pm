package CPAN::Flatten::Distributions::Emitter;
use strict;
use warnings;

sub new {
    my ($class, %opt) = @_;
    bless {%opt}, $class;
}

sub print {
    my ($self, $indent, $message) = @_;
    my $fh = $self->{fh};
    print {$fh} "  " x $indent, $message, "\n";
}

sub emit {
    my ($self, $distributions, $fh) = @_;
    $self = $self->new(fh => $fh) unless ref $self;

    for my $distribution (@$distributions) {
        next if $distribution->is_core;
        $self->print(0, $distribution->distfile);
        my %requirements;
        for my $requirement (@{$distribution->requirements}) {
            my $providing = $distributions->providing_distribution(
                $requirement->{package}, $requirement->{version},
            );
            if (!$providing) {
                warn "missing $requirement->{package}";
                next;
            } elsif ($providing->is_core) {
                next;
            }
            push @{$requirements{$requirement->{phase}}}, $providing->distfile;
        }
        next unless %requirements;
        for my $phase (qw(configure build runtime)) {
            my $requirements = $requirements{$phase} or next;
            $self->print(1, "${phase}_requires");
            for my $requirement (@$requirements) {
                $self->print(2, $requirement);
            }
        }
    }
}



1;
