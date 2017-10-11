package Taz::Article;
use Mojo::Base -base;
use Mojo::Util 'trim', 'dumper';
use Taz::Author;

has 'tree';
has lead   => sub { shift->tree->find('lead')->map('all_text')->first   || '' };
has kicker => sub { shift->tree->find('kicker')->map('all_text')->first || '' };
has headline =>
  sub { $_[0]->tree->find('headline')->map('all_text')->first || '' };
has corpus => sub {
    my $corpus = shift->tree->at('corpus');
    $corpus->find('b')->map( sub { $_->content( '*' . $_->content . '*' ) } );
    $corpus->find('h6')
      ->map( sub { $_->content( '# ' . $_->content . ' #' ) } );
    $corpus->descendant_nodes->map('strip')
      ->map( sub { $_->content( trim( $_->content ) ) } );
    return $corpus->content;
};

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

has 'tags' => sub {
    [ map { Taz::Tag->new( tree => $_ ) } shift->tree->find('tag')->each ];
};

package Taz::Tag;
use Mojo::Base -base;

has 'tree';
has title => sub { shift->tree->at('title')->all_text };
has link  => sub { '/!t' . shift->tree->attr('id') };

1;
