#!/usr/pkg/bin/perl -w

use strict;
my $me = 'feed-fzdb.pl';

use vars qw( %task );

$task{$me}{timespec} = '30 * * * *';
$task{$me}{timespec_panic_1} = ''; # not important
$task{$me}{code} = sub {
        my($virtual_user, $constants, $slashdb, $user) = @_;
        my $bd = $constants->{basedir}; # convenience

# sub routines. ###############
	sub dumpHTMLText {
	    my($response) = @_;
	    my $charset = getCharset($response);
	    my $content = $response->content;
	    $content =~ s/<.*?>//sg;
	    $content =~ s/&(\w+?|\#\d+);/ /sg;
	    $content =~ s/(\s)\s+/$1/sg;
	    from_to($content,$charset,"utf8");
	    return $content;
	}
###############################

	use Slash::FuzzyIndex;
	my $fz = Slash::FuzzyIndex->new($virtual_user);

	my $urls = $fz->getUrls({
	    updated => 1,
	    type    => "html",
	});

	require LWP::UserAgent;
	my $ua = LWP::UserAgent->new(timeout => 60);
	foreach my $u (@$urls) {
	    my $url = $u->{url};
	    my $response = $ua->get($url);
	    if ($response->is_success) {
		my $txt = dumpHTMLText($response);
		$fz->delete({
		    url   => $url,
		    title => $u->{title},
		});
		$fz->insert({
		    url   => $url,
		    title => $title,
		    text  => $txt,
		});
		$fz->fz
	    } else {
		$error = 1;
	    }
	}
};
