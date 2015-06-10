requires 'perl', '5.008005';
requires 'HTTP::Tiny';
requires 'IO::Socket::SSL';


on test => sub {
    requires 'Test::More', '0.96';
};
