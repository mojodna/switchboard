# Switchboard 

Switchboard is both a toolkit for assembling XMPP clients as well as a set of
command-line tools for interacting with XMPP servers.

## Getting Started

Install it:

    $ gem install mojodna-switchboard -s http://gems.github.com

Configure it:

    $ switchboard config jid jid@example.com
    $ switchboard config password pa55word
    $ switchboard config oauth.consumer_key asdf
    $ switchboard config oauth.consumer_secret qwerty
    $ switchboard config oauth.token asdf
    $ switchboard config oauth.token_secret qwerty
    $ switchboard config oauth.general_token asdf
    $ switchboard config oauth.general_token_secret qwerty
    $ switchboard config pubsub.server fireeagle.com

_Settings will be stored in `$HOME/.switchboardrc`_

Run it:

    $ switchboard <command> <args>
    $ switchboard roster list
    $ switchboard roster add fireeagle.com
    $ ...