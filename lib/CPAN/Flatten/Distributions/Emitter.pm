package CPAN::Flatten::Distributions::Emitter;
use strict;
use warnings;

# tweak Carton::Snapshot::Emitter for separating requirements: configure, build, runtime

sub emit {
    my ($class, $distributions) = @_;

    my $data = '';
    $data .= "DISTRIBUTIONS\n";
    for my $distribution (@$distributions) {
        $data .= "  @{[$distribution->name]}\n";
        $data .= "    pathname: @{[$distribution->distfile]}\n";

        $data .= "    provides:\n";
        for my $provide (@{$distribution->provides}) {
            $data .= "      $provide->{package} @{[$provide->{version} || 'undef' ]}\n";
        }

        my %requirements;
        for my $requirement (@{$distribution->requirements}) {
            push @{$requirements{$requirement->{phase}}}, "$requirement->{package} $requirement->{version}";
        }
        $data .= "    requirements:\n";
        for my $phase (qw(configure build runtime)) {
            my $requirements = $requirements{$phase} or next;
            $data .= "      $phase:\n";
            for my $requirement (@$requirements) {
                $data .= "        $requirement\n";
            }
        }
    }

    $data;
}

1;
