
package Slash::FuzzyIndex;

use strict;
use OurNet::FuzzyIndex;
use Encode;

use vars qw($VERSION @EXPORT);
use Slash::Display;
use Slash::Utility;
use YAML;

use base 'Exporter';
use base 'Slash::DB::Utility';
use base 'Slash::DB::MySQL';

$VERSION = '0.4';

=head1 NAME

Slash::FuzzyIndex - Slash Plugin for OurNet::FuzzyIndex

=head1 DESCRIPTION

This module implements the fuzzy-text search for Slash system,
using OurNet::FuzzyIndex indexing engine.

=cut

sub new {
    my($class, $user) = @_;
    my $self = {};

    my $slashdb = getCurrentDB();
    my $plugins = $slashdb->getDescriptions('plugins');
    return unless $plugins->{'FuzzyIndex'};

    my $constants = getCurrentStatic();

    $self = { 
   	fzdbfile => $constants->{datadir} . "/fz.main.db" ,
    };

    $self->{fzdb} = OurNet::FuzzyIndex->new($self->{fzdbfile});

    bless($self, $class);
    $self->{virtual_user} = $user;
    $self->sqlConnect;

    return $self;
}

# XXX - temporarily unused.
#sub getDbList {
#    my ($self,$constants) = @_;
#    my $dbs = [];
#    map { /fz\.(.+)\.db/ && push @{$dbs},$1 }
#    glob("$constants->{datadir}/fz.*");
#
#    return $dbs;
#}

# Fields in $obj
#  text: full text content of this entry
#  title: Sort sentence presententing this entry
#  url: url of this entry
sub insert {
    my ($self,$obj) = @_;
    return unless ($self->{fzdb} &&
		   $obj->{url} && $obj->{title} && $obj->{text});

    my $content = $obj->{text};
    my $title   = $obj->{title};
    my $url     = $obj->{url};

    Encode::from_to($title  ,'utf8','big5');
    Encode::from_to($url    ,'utf8','big5');
    Encode::from_to($content,'utf8','big5');

    my $key = { url     => $url,
		title   => $title
		};

    return $self->{fzdb}->insert(Dump($key),$content);
}

sub delete {
    my ($self,$key) = @_;
    return unless ($self->{fzdb});

    my $title   = $obj->{title};
    my $url     = $obj->{url};

    Encode::from_to($title  ,'utf8','big5');
    Encode::from_to($url    ,'utf8','big5');

    my $key = { url     => $url,
		title   => $title
		};

    return $self->{fzdb}->delete(Dump($key));
}

# return a arrayref of hashref(objects)
sub query {
    my ($self,$key) = @_;
    return unless ($self->{fzdb});

    Encode::from_to($key,'utf8','big5');

    my @results;
    my %_result = $self->{fzdb}->query($key);
    foreach my $idx (sort {$_result{$b} <=> $_result{$a}} keys(%_result) {
	my $score = $_result{$idx};
	my $k = Load($self->{fzdb}->getkey($idx));
	Encode::from_to($k->{title},'big5','utf8');
	Encode::from_to($k->{url},'big5','utf8');
	my $entry =  { score  => $score ,
		       title  => $k->{title},
		       url    => $k->{url}
		   };
	push @results,$entry;
    }
    return @results;
}

# sub routines.
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

sub getUrls {
    my ($self,$param) = @_;
    my $where = undef;
    if($param->{updated}) {
	$where = "lastmdfy > lastchk";
    }

    if($param->{type} =~ /rss/i) {
	$where = 'type="rss"';
    }elsif($param->{type} =~ /html/i) {
	$where = 'type="html"';
    }elsif($param->{type} =~ /text/i){
	$where = 'type="text"';
    }

    my $slashdb = getCurrentDB();

    my $urls = $slashdb->sqlSelectAllHashrefArray('id,url,title','fzidxurls',$where);

    return $urls;
}

sub addUrls {
    my ($self,$param) = @_;

    my $user = getCurrentUser();
    my $slashdb = getCurrentDB();

    if($param->{type} =~ /rss/i) {
	$type = 'rss';
    }elsif($param->{type} =~ /html/i) {
	$type = 'html';
    }else{
	$type = 'text';
    }

    return $slashdb->sqlInsert
	('fzidxurls',
	 { url => $param->{url},
	   uid => $user->{uid},
	   type => $type,
       });

}

sub updateUrlMdfy {
    my ($self,$id,$time) = @_;
    my $slashdb = getCurrentDB();
    return $slashdb->sqlUpdate
	('fzidxurls', { lastmdfy => $time} ,"id=${id}");
}

1;

__END__

=head1 AUTHORS

Kang-min Liu E<lt>gugod@gugod.orgE<gt>.

=head1 COPYRIGHT

Copyright 2003 by Kang-min Liu E<lt>gugod@gugod.orgE<gt>.

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
