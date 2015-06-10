package CPAN::Flatten::Artifact::Factory;
use strict;
use warnings;
use HTTP::Tiny;
use IO::Socket::SSL;
use CPAN::Meta::YAML;
use JSON::PP ();
use CPAN::Flatten::Artifact;

my $SELF = __PACKAGE__->_new(
    distfile_url => "http://cpanmetadb.plackperl.org/v1.0/package",
    provides_url => "https://cpanmetadb-provides.herokuapp.com/v1.0/provides",
    dependencies_url => "https://api.metacpan.org/release",
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
    my $dependencies = $SELF->fetch_dependencies($distfile);
    if (!$dependencies) {
        return unless $need_reason;
        return (undef, "failed to fetch dependencies for $distfile");
    }

    CPAN::Flatten::Artifact->new(
        name => $distfile,
        provides => $provides,
        dependencies => $dependencies,
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
sub fetch_dependencies {
    my ($self, $distfile) = @_;
    $distfile =~ s{^./../}{};
    $distfile =~ s{\.(?:tar\.gz|zip|tgz)$}{};
    my $res = $self->{ua}->get($self->{dependencies_url} . "/$distfile");
    return unless $res->{success};
    if (my $json = eval { JSON::PP::decode_json($res->{content}) }) {
        my $dependencies = $json->{dependency} or return;

        for my $dep (@$dependencies) {
            my $relationship = delete $dep->{relationship}; # requires/suggests...
            my $module = delete $dep->{module};
            my $version_numified = delete $dep->{version_numified};
            $dep->{type} = $relationship;
            $dep->{package} = $module;
        }

        my @want = grep { $_->{type} eq "requires" }
                   grep {
                       my $dep = $_;
                       !!grep {$dep->{phase} eq $_} qw(configure build runtime);
                    } @$dependencies;
        return [@want];
    }
    return;
}

1;
