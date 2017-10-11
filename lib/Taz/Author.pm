package Taz::Author;
use Mojo::Base -base;

has 'tree';
has name => sub { shift->tree->at('name')->text };
has url  => sub { shift->tree->find('url path[rel="canonical"]')->map(attr => 'href')->first };

1;
