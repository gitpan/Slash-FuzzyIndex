#!/usr/local/bin/perl -w

use strict;
use Slash 2.001;	# require Slash 2.1
use Slash::Display;
use Slash::Utility;
use Slash::XML;
use vars qw($VERSION);

use Encode qw(from_to encode decode);
use LWP::Charset qw(getCharset);
use OurNet::FuzzyIndex;

use constant ALLOWED    => 0;
use constant FUNCTION   => 1;

our $VERSION = '0.02';

sub main {
	my $self      = getObject('Slash::FuzzyIndex');
	my $constants = getCurrentStatic();
	my $slashdb   = getCurrentDB();
	my $user      = getCurrentUser();
	my $form      = getCurrentForm();

 	my %ops = (
 		insert	=> [ 1,	\&showInsert  ] ,
 		query	=> [ 1,	\&showQuery   ] ,
 		default	=> [ 1,	\&showMain    ] ,
 	);

 	my $op = $form->{'op'};
  	if (!$op || !exists $ops{$op} || !$ops{$op}[ALLOWED]) {
 		$op = 'default';
 	}

	$ops{$op}[FUNCTION]->($self,$slashdb,$constants, $user, $form);
}

sub showInsert {
    my($self,$slashdb,$constants,$user,$form) = @_;

    my $url = $form->{url};
    my $title = $form->{title};
    my $msg ;
    my $error = undef;

    use LWP::UserAgent;

    my $ua = LWP::UserAgent->new(timeout => 10);
    my $response = $ua->get($url);
    if ($response->is_success) {
	my $txt = $self->dumpHTMLText($response);
	$self->insert({
		url   => $url,
		title => $title,
		text  => $txt,
	});
	$msg = "URL_INSERTED";
    } else {
	$msg   = "CANNOT_RETRIEVE_URL";
	$error = 1;
    }

    header("FuzzyIndex / Insertion");
    slashDisplay('insert', {
	    msg => $msg,	
	    form => $form ,
	    error => $error,
	    });
    footer();
}

sub showQuery  {
    my($self,$slashdb,$constants,$user,$form) = @_;

    my $t = $form->{txt};

    my @results = $self->query($t);

    header("FuzzyIndex / Query Results");
    slashDisplay('result', { results => \@results });
    footer();
}

sub showMain {
    my($self,$slashdb,$constants,$user,$form) = @_;

    header("FuzzyIndex / Query");
    slashDisplay('main',
 		 {title	=> "Fuzzy Search",
		  form  => $form,
 		 });
    footer();
}

createEnvironment();
main();
1;

