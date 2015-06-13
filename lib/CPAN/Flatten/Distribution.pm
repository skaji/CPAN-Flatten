package CPAN::Flatten::Distribution;
use strict;
use warnings;
use Module::CoreList;

my $core_distribution = CPAN::Flatten::Distribution->new(
    distfile => undef,
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
    requirements => [],
);

sub core {
    return $core_distribution;
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

sub requirements {
    shift->{requirements} || [];
}

sub name {
    my $self = shift;
    return $self->{name} if $self->{name};
    my $distfile = $self->distfile
        or return;
    if ($distfile =~ m{^./../[^/]+/(.+)\.(?:tar\.gz|zip|tgz)$}) {
        return $1;
    } else {
        return;
    }
}

sub distfile {
    shift->{distfile};
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
