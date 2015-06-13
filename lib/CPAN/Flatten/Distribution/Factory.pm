package CPAN::Flatten::Distribution::Factory;
use strict;
use warnings;
use HTTP::Tiny;
use IO::Socket::SSL;
use CPAN::Meta::YAML;
use JSON::PP ();
use CPAN::Flatten::Distribution;

my $SELF = __PACKAGE__->_new(
    distfile_url => "http://cpanmetadb.plackperl.org/v1.0/package",
    provides_url => "https://cpanmetadb-provides.herokuapp.com/v1.0/provides",
    requirements_url => "https://api.metacpan.org/release",
    ua => HTTP::Tiny->new(timeout => 10),
);


sub from_pacakge {
    my ($class, $package, $version) = @_;
    my $need_reason = wantarray;

    my $distfile = $SELF->fetch_distfile($package, $version);
    if (!$distfile) {
        return unless $need_reason;
        return (undef, "failed to fetch distfile for $package");
    }
    my $provides = $SELF->fetch_provides($distfile);
    if (!$provides) {
        return unless $need_reason;
        return (undef, "failed to fetch provides for $distfile");
    }
    my $requirements = $SELF->fetch_requirements($distfile);
    if (!$requirements) {
        return unless $need_reason;
        return (undef, "failed to fetch requirements for $distfile");
    }

    CPAN::Flatten::Distribution->new(
        distfile => $distfile,
        provides => $provides,
        requirements => $requirements,
    );
}

sub _new {
    my ($class, %opt) = @_;
    bless {%opt}, $class;
}

sub fetch_distfile {
    my ($self, $package, $version) = @_;
    my $res = $self->{ua}->get( $self->{distfile_url} . "/$package" );
    return unless $res->{success};

    if (my $yaml = CPAN::Meta::YAML->read_string($res->{content})) {
        my $meta = $yaml->[0];
        return $meta->{distfile} if $meta && $meta->{distfile};
    }
    return;
}

sub fetch_provides {
    my ($self, $distfile) = @_;
    my $res = $self->{ua}->get($self->{provides_url} . "/$distfile");
    return unless $res->{success};
    if (my $yaml = CPAN::Meta::YAML->read_string($res->{content})) {
        my $meta = $yaml->[0];
        return $meta->{provides} if $meta && $meta->{provides};
    }
    return;
}

# from CPAN::Meta:
# phase: configure build test runtime develop
# type:  requires recommends suggests conflicts
# eg: https://api.metacpan.org/release/MIYAGAWA/Plack-1.0036
sub fetch_requirements {
    my ($self, $distfile) = @_;
    $distfile =~ s{^./../}{};
    $distfile =~ s{\.(?:tar\.gz|zip|tgz|tar\.bz2)$}{};
    my $res = $self->{ua}->get($self->{requirements_url} . "/$distfile");
    return unless $res->{success};
    if (my $json = eval { JSON::PP::decode_json($res->{content}) }) {
        my $requirements = $json->{dependency} or return;

        for my $requirement (@$requirements) {
            my $relationship = delete $requirement->{relationship}; # requires/suggests...
            my $module = delete $requirement->{module};
            my $version_numified = delete $requirement->{version_numified};
            $requirement->{type} = $relationship;
            $requirement->{package} = $module;
        }

        my @want = grep { $_->{type} eq "requires" }
                   grep {
                       my $requirement = $_;
                       !!grep {$requirement->{phase} eq $_} qw(configure build runtime);
                    } @$requirements;
        return [@want];
    }
    return;
}

1;
