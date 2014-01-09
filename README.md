Anidown
=======

About
-----
Anidown started out as a simple anime batch downloader for Chinese Linuxers. (For those who don't know, ''anime'' basically means ''Japanese cartoon''.) But it is becoming more and more general-purpose. The developer will strive to adhere to the Unix philosophy, so that Anidown can be exploited by other programs.

Anidown finds sources of animes by parsing search results from Soku.com. Then it queries Flvcd.com to get URLs of each episode and downloads them.

Anidown is a complete rewrite of my previous works, and it is under heavy development, so please be patient if it doesn't have feature XXX.

Finally, if you're willing to help improve Anidown, please do so. Any contribution will be much appreciated.

### Goal
* simple
* fast (not achieved yet)
* Unixy (not achieved yet)

Usage
-----
### configure Anidown
`./make` (NOTE that this is a shell script and has nothing to do with Make)

This script doesn't do much for now, so you can skip the configure step. After `./make` is run, all the programs we need will be put into bin/.

### running Anidown
Anidown provides two commandline interfaces: dwrapper.sh and watch.sh (dwrapper means ''downloader wrapper''). To invoke them, you can simply run `./dwrapper.sh blahblahblah` or `./watch.sh`. You can also include the path to Anidown in your search path:
    export PATH="path/to/anidown:$PATH"
    watch.sh

Please note that there are also other scripts in the Anidown directory, which are not supposed to be invoked directly. This problem will hopefully be solved by a launcher script in upcoming updates.

### download a video
    dwrapper.sh http://myurl

Note that we can download only one video at a time. Extra URLs will be considered invalid commandline arguments and Anidown will complain. This behavior is intentional, as it aviods [surprise](http://en.wikipedia.org/wiki/Principle_of_least_astonishment). If you want to download several videos in a row, read on to know how.

### download a bunch of videos
    dwrapper.sh < my_video_list

If no URL is given in commandline arguments, Anidown will read from stdin a list of videos to be downloaded. Each line contains exactly one URL. Empty lines will not be downloaded, but they *DO* affect the numbering of output directories. This annoying behavior will be changed in the future.

### download an anime
Currently Anidown doesn't provide any direct way to download animes automatically, but we do provide a way to do it indirectly. See below for the usage of watch.sh.

### stay tuned for ongoing animes
    editor watchlist
    watch.sh

watch.sh will read a list of seasons from watchlist, and download all new episodes automatically.

Note that the watchlist file should be placed in CWD, not in the Anidown directory.

watchlist syntax:

        anime1
        season1
        site1

        anime2
        season2
        site2

        ...

        animeN
        seasonN
        siteN

(Note: There must be a empty line between adjacent items.)
(Note also: The current version requires you to give a season name that exactly matches the HTML source. So make sure that you didn't forget any spaces)

### commandline arguments
Here are some frequently used options. Run `dwrapper.sh --help` or `watch.sh --help` for a complete list of commandline arguments.
-o PATH save videos in PATH instead of CWD
-c      try to continue downloading (by default, Anidown skips existing files/directories)
-q      suppress progress report
-L FILE save log to FILE

### exit status
0 means Anidown finished its job and exited successfully
1 means Anidown did nothing useful, but exited successfully (so we can do things like `watch.sh && echo 'new episodes found!'`)
2 means something goes wrong

Misc notes
----------
### Legal issues
Anidown is licensed under Apache License, Version 2.0.

The source code is completely legal. However, its usage might **NOT** be. Please consult a lawyer if you are not living in Mainland China.

### Why Anidown?
Flash is really dirty. So does Flash players on Linux. Gnash is known to have problems with almost every website in China, and the *proprietary* ~~Adobe Flash Player~~ runs really slow. Conclusion: Linux doesn't really support Flash. (or more precisely, Flash doesn't support Linux)

But most online video hosting websites in China rely on Flash...

So why don't we download all the videos and view them offline with our favorite media players? Grab Anidown and start enjoying the latest animes now!

### Why not Dantalian.rb?
I wrote a Ruby script called dantalian.rb, which does pretty much the same thing as Anidown does. However, it is very user-friendly (translation: bloated and inefficient), so I decided to replace it with Anidown, which is much slimmer.

Don't worry. I'm working on dantalian.rb to turn it into a frontend of Anidown. So you can get your easy-to-use interactive downloader back within a month or so.

### This repo is a mirror
Sadly, the mercurial-git package (Wheezy) doesn't work for me, so I have to put up with different SCMs.

This repo is actually a Mercurial repo, and Git is only used as a tool to upload/download files to/from Github. That's why the commit history doesn't make sense.

Since the Git repo doesn't keep track of the actual commits, it is not supposed to be used as a collaborative tool. If you want to contribute:

1. upload your code and send me a pull request, or

2. send me a patch

Sorry for the inconvenience.

I plan to move the repo to [Bitbucket.org](https://bitbucket.org/), so that things will get easier.

If you know how to fix the mercurial-git bug or have any good suggestions about a better workaround, please tell me.
