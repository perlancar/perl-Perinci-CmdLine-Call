package Perinci::CmdLine::Call;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(call_cli_script);

our %SPEC;

$SPEC{call_cli_script} = {
    v => 1.1,
    summary => '"Call" a Perinci::CmdLine-based script',
    description => <<'_',

CLI scripts which use `Perinci::CmdLine` module family (e.g.
`Perinci::CmdLine::Lite` or `Perinci::CmdLine::Classic`) have some common
features, e.g. support JSON output.

This routine provides a convenience way to get a data structure from running a
CLI command. It basically just calls the script with `--json` and
`--no-naked-res` then decodes the JSON result so you get a data structure
directly. Will die if output is not valid JSON.

Other features might be added in the future, e.g. retry, custom configuration
file, etc.

_
    args => {
        script => {
            schema => 'str*',
            req => 1,
        },
        argv => {
            schema => ['array*', of=>'str*'],
            default => [],
        },
    },
};
sub call_cli_script {
    require IPC::System::Options;
    require JSON::MaybeXS;

    my %args = @_;

    my $script = $args{script};
    my $argv   = $args{argv} // [];

    my $res = IPC::System::Options::readpipe(
        {die=>0, log=>1},
        $script, "--json", "--no-naked-res", @$argv,
    );

    eval { $res = JSON::MaybeXS::decode_json($res) };
    die "Can't decode JSON: $@, res=<$res>" if $@;

    $res;
}

1;
# ABSTRACT: "Call" a Perinci::CmdLine-based script

=head1 SYNOPSIS

 use Perinci::CmdLine::Call qw(call_cli_script);

 # returns an enveloped response
 my $res = call_cli_script(
     script => "lcpan",
     argv   => [qw/deps -R Text::ANSI::Util/],
 );

 # sample result:
 # [200, "OK", [
 #     {author=>"PERLANCAR", module=>"Text::WideChar::Util", version=>"0.10"},
 #     {author=>"NEZUMI"   , module=>"  Unicode::GCString" , version=>"0"},
 #     {author=>"NEZUMI"   , module=>"    MIME::Charset"   , version=>"v1.6.2"},
 # ]]


=head1 DESCRIPTION


=head1 SEE ALSO

L<Perinci::CmdLine>, L<Perinci::CmdLine::Lite>, L<Perinci::CmdLine::Classic>

L<Rinci>

=cut
