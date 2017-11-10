package Taz::Article;
use Mojo::Base -base;
use Mojo::Util 'trim', 'dumper';
use Taz::Author;
use Text::Wrap ();

has 'tree';
has lead   => sub { shift->tree->find('lead')->map('all_text')->first   || '' };
has kicker => sub { shift->tree->find('kicker')->map('all_text')->first || '' };
has headline =>
  sub { $_[0]->tree->find('headline')->map('all_text')->first || '' };
has corpus => sub { shift->tree->at('corpus') };

has id => sub {
    shift->tree->children('meta')->first->at('id[scope="url"]');
};

has url => sub {

    # url path canonical is missing sometimes (gazete)
    '/!' . shift->tree->children('meta')->first->at('id[scope="url"]')->text;
};

has authors => sub {
    my $self = shift;
    [
        map { Taz::Author->new( tree => $_ ) }
          $self->tree->find('content > item > author')->each,
        $self->tree->children('author')->each
    ];
};

has published => sub {
    my $n   = shift->tree->at('meta published dt');
    my $y   = $n->at('y')->text;
    my $mon = $n->at('mon')->text;
    my $day = $n->at('day')->text;
    return "$day.$mon.$y";
};

has 'tags' => sub {
    [ map { Taz::Tag->new( tree => $_ ) } shift->tree->find('tag')->each ];
};

sub render_corpus {
    my $content = _render( shift->corpus );
}

sub _render {
    my $node    = shift;
    my $content = '';
    for ( $node->child_nodes->each ) {
        $content .= _render($_);
    }
    if ( $node->tag && $node->tag eq 'h1' ) {
        return "$content\n" . ( '=' x length($content) ) . "\n\n";
    }
    if ( $node->tag && $node->tag =~ /^h(\d)$/ ) {
        return ( '#' x $1 ) . " $content\n\n";
    }
    elsif ( $node->type eq 'text' ) {
        $content = $node->content;
        $content =~ s/\.\s\.\s\./.../;
        return '' if $content !~ /\S/;
        return $content;
    }
    elsif ( $node->type eq 'tag' && $node->tag eq 'location' ) {
        return "$content ";
    }
    elsif ( $node->type eq 'tag' && $node->tag eq 'p' ) {
        return Text::Wrap::fill( '', '', $content ) . "\n\n";
    }
    elsif ( $node->type eq 'tag' && $node->tag eq 'b' ) {
        return "*$content*";
    }
    else {
        return $content;
    }
}

package Taz::Tag;
use Mojo::Base -base;

has 'tree';
has title => sub { shift->tree->at('title')->all_text };
has link  => sub { '/!t' . shift->tree->attr('id') };

1;
