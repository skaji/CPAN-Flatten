requires 'perl', '5.008005';
requires 'CPAN::Meta::YAML';
requires 'HTTP::Tiny';
requires 'Module::CoreList';
requires 'parent';

on test => sub {
    requires 'Test::More', '0.96';
};
