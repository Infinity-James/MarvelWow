# Marvel Wow

This app will list all Marvel comics from today back to the beginning of time.
Not only can you scroll through a seemingly infinite list of comics, but you
can change the cover image for any of them, and save it to your Dropbox so that
you can see that cover image every time you zoom past the comic in the list.

### Choose Your Own Cover

The user can tap on any comic in the list and change the cover to any photo 
currrently in their photo library, or a newly taken photo.

### Marvel API

Within this app is an intelligent and expansable mechanism to query Marvel's
API. It is built upon the idea of queries themselves being values types to be
passed around and executed within the Marvel API client.

Whilst this app only feature comics the API has been designed in such a way
that any of the Marvel resources can be fetched if such functionality should
need to exist in the future.

### Caching

We don't want to have to load every comic from the server every time! You'll be
waiting 10 seconds just to see the comic book images if we have to get them
over and over again.

Introducing: the idea of caching! We cache the comic covers so that as you
scroll through the feed you can see the bautiful comics (maybe with your own
covers) without waiting for ever,

### Dropbox

When the user wishes to provide a custom image for a comic, if they are anot
already, they will be asked to log in to Dropbox where a MarvelWow folder will
be created and the personalised comic book cover images will exist.

### Tests

Tests are the Peter Parker of programming. They're unassuming, nerdy, and
people make fun of them. When you're in trouble though, they save your butt.
Without tests it would have been way harder to get my client working properly.

The only problem is, I didn't get to write enough of them! Time is a cruel
mistress, and in a coding challenge there is never enough of it. I am happy
with what is there, but there would ideally be more.

There should be more UI coverage, but more importantly there should be tests
for caching system, image fetch operations, and far more tests for the client
and queries.

### CocoaPods

This app uses the framework package manager CocoaPods. Currently the only 
supported way to use the flashy new SwiftDropbox SDK is through CocoaPods.
