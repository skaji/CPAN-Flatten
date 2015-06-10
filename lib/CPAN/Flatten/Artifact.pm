package CPAN::Flatten::Artifact;
use strict;
use warnings;
use Module::CoreList;

my $core_artifact = CPAN::Flatten::Artifact->new(
    name => "perl-$^V",
    provides => do {
        my @provides;
        for my $package (sort keys %{$Module::CoreList::version{$]}}) {
            push @provides, {
                package => $package,
                version => $Module::CoreList::version{$]}{$package},
            };
        }
        \@provides;
    },
    dependencies => [],
);

sub core {
    return $core_artifact;
}

sub is_core {
    my $self = shift;
    return $self->name eq "perl-$^V";
}

sub new {
    my ($class, %opt) = @_;
    bless {%opt}, $class;
}

sub provides {
    shift->{provides} || [];
}

sub dependencies {
    shift->{dependencies} || [];
}

sub name {
    shift->{name};
}

sub distfile {
    shift->name;
}

sub providing {
    my ($self, $package, $version) = @_;
    my $provides = $self->provides;
    for my $provide (@$provides) {
        return 1 if $provide->{package} eq $package;
    }
    return;
}

1;
