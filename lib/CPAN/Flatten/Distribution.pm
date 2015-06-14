package CPAN::Flatten::Distribution;
use strict;
use warnings;
use Module::CoreList;
use CPAN::Flatten::Distribution::Emitter;

use parent 'CPAN::Flatten::Tree';

sub is_dummy {
    shift->{dummy};
}

sub dummy {
    my $self = shift;
    my $class = ref $self;
    $class->new(distfile => $self->distfile, dummy => 1);
}

sub provides {
    shift->{provides} || [];
}

sub requirements {
    shift->{requirements} || [];
}

sub distfile {
    shift->{distfile};
}

sub is_core {
    my ($self, $package, $version) = @_;
    return 1 if $package eq "perl";
    return 1 if exists $Module::CoreList::version{$]}{$package};
    return;
}

use constant STOP => -1;

sub providing {
    my ($self, $package, $version) = @_;

    my $providing;
    $self->walk_down(sub {
        my ($node, $depth) = @_;
        $providing = $node->_providing_by_myself($package, $version);
        return STOP if $providing;
    });
    return $providing;
}

sub _providing_by_myself {
    my ($self, $package, $version) = @_;
    for my $provide (@{$self->provides}) {
        return $self if $provide->{package} eq $package;
    }
    return;
}

sub emit {
    my ($self, $fh) = @_;
    CPAN::Flatten::Distribution::Emitter->emit($self, $fh);
}

1;
