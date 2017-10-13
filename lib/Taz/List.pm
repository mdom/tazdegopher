package Taz::List;
use Mojo::Base -base;
use Taz::Article;

has 'tree';
has 'length';

has title => sub { shift->tree->at('directory > title')->all_text };
has items => sub {
    [ map { Taz::Article->new( tree => $_ ) }
          shift->tree->find('directory > list > item')->each ];
};
has url => sub {
    shift->tree->at('directory meta url path[rel="canonical"]')->attr('href');
};

1;
