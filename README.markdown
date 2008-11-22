# Switchboard 

Switchboard is both a toolkit for assembling XMPP clients as well as a set of
command-line tools for interacting with XMPP servers.

## Getting Started

Install it:

    $ sudo gem install mojodna-switchboard -s http://gems.github.com

Configure it:

    $ switchboard config jid jid@example.com
    $ switchboard config password pa55word

_Settings will be stored in `$HOME/.switchboardrc`_

Run it:

    $ switchboard <command> <args>
    $ switchboard roster list
    $ switchboard roster add fireeagle.com
    $ ...

Subscribe to a node using OAuth, overriding default settings:

    $ switchboard --jid subscriber@example.com --password pa55word \
        pubsub --oauth \
        --oauth-consumer-key <consumer key> \
        --oauth-consumer-secret <consumer secret> \
        --oauth-token <token> \
        --oauth-token-secret <token secret> \
        --server fireeagle.com \
        --node "/api/0.1/user/<token>" \
        subscribe

Publish iTunes' current track using UserTune (XEP-0118):

    $ switchboard --resource switchtunes pep tune

_You can do this using a JID that is already online._
