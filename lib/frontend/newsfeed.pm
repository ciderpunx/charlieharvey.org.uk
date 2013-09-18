package frontend::newsfeeds;
use utf8;
use Dancer ':syntax';
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Plugin::Feed;

prefix '/newsfeeds';

# view of all our feeds kind of smushed together
get '/' => sub {
# redirect  uri_for('');
};

# recent shit from the feeds I read
get '/api/recent' => sub {

};

# recent shit from feeds as a feed itself. Meta.
get '/rss' => sub {

};

## 
# Occasionally fetch our various feeds with an external script and merge them
# into one massiv one
# We pull them out using, maybe http://search.cpan.org/~lcarmich/Dancer-Plugin-XML-RSS-0.01/lib/Dancer/Plugin/XML/RSS.pm
# and then pull them into the various functions.
