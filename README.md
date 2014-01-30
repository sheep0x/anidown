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

After `./make` is run, all the programs we need will be put into bin/.

This script doesn't do much for now, so you can skip the configure step.

### run Anidown
Anidown provides two commandline interfaces: dwrapper.sh and watch.rb (dwrapper means ''downloader wrapper''). To invoke them, you can simply run `./dwrapper.sh` or `./watch.rb`. You can also include the path to Anidown in your search path:

```shell
export PATH="path/to/anidown:$PATH"
watch.rb
```

Please note that there are also other scripts in the Anidown directory, which are not supposed to be invoked directly. This problem will hopefully be solved by a launcher script in upcoming updates.

### download a video
```shell
dwrapper.sh http://myurl
```

Note that we can download only one video at a time. Extra URLs will be considered invalid commandline arguments and Anidown will complain. This behavior is intentional, as it [aviods inconsistent behavior](http://en.wikipedia.org/wiki/Principle_of_least_astonishment). If you want to download several videos in a row, see below.

### download a bunch of videos
```shell
dwrapper.sh < my_video_list
```

If no URL is given in commandline arguments, Anidown will read from stdin a list of videos to be downloaded. Each line contains exactly one URL. Empty lines will not be downloaded, but they *DO* affect the numbering of output directories. This annoying behavior is necessary for watch.rb to work correctly, but it will be changed in the future.

Currently dwrapper.sh puts downloaded videos in numbered directories, rather than named directories. Named directories willbe supported in upcoming updates.

### download an anime
Currently Anidown doesn't provide any direct way to download animes automatically, but we do provide a way to do it indirectly. See below for the usage of watch.rb.

### stay tuned for ongoing animes
```shell
editor watchlist
watch.rb
```

Everytime you run watch.rb, it will read a list of seasons from watchlist, and download all new episodes automatically. (Hint: you can make it a cron job if you like)

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

(Note: There must be at least one empty line between adjacent items.)

(Note also: The current version requires you to give a season name that exactly matches the HTML source. So make sure that you didn't forget any spaces)

Anidown doesn't really check if an episode is ''new'' in terms of date and time. It considers all videos that are available online but not downloaded yet to be ''new''. So if you tell Anidown to check for new episodes of an anime you've never downloaded, Anidown will consider all episodes to be ''new'' and thus download every available episode.

Trick: If you want to download parts of an anime, you can create empty directories to fool Anidown. When neither --continue nor --force is supplied, Anidown skips existing directories even if they are empty. Say you want to download episodes 7~12:

```shell
$ cd output/myanime/season1
$ mkdir -p {1..6} {13..100}     # suppose we're using Bash
$ cd -
...
$ watch.rb
...
```

### commandline arguments
Here are some frequently used options. Run `dwrapper.sh --help` or `watch.rb --help` for a complete list of commandline arguments.

 option | meaning
------- | ----------------------
-o PATH | save videos in PATH instead of CWD
-c      | try to continue downloading (by default, Anidown skips existing files/directories)
-q      | suppress progress report
-L FILE | save log to FILE

### exit status
value | meaning
----- | -----------------------
0     | Anidown finished its job and exited successfully
1     | Anidown did nothing useful, but exited successfully (so we can do things like `watch.rb && echo 'new episodes found!'`)
2     | something went wrong and Anidown broke down
3     | something went wrong but it wasn't Anidown's fault (For example, the input is invalid)

Common problems
---------------
### Anidown failed to resolve a video
If you see something like `[2014-01-29 21:07:19] failed to resolve, please check if the video is valid`:

1. View the video in your browser to check if it is valid. Sometimes the video could be invalid even if its corresponding page exists. For example, the video could be deleted.

2. Goto [Flvcd.com](http://www.flvcd.com/) and check if it can resolve the video. If you are sure that the video is valid and Flvcd.com can't resolve it, it is a problem of Flvcd.com, not a bug of Anidown.

3. If Flvcd.com works well, then you've probably found a bug of Anidown. Please tell me about it.

Misc notes
----------
### Legal issues
Anidown is licensed under Apache License, Version 2.0.

The source code is completely legal. However, its usage might **NOT** be. Please consult a lawyer if you are not living in Mainland China.

### Compatibility
Anidown is tested against Ruby 1.9.3 and Bash 4.2. Support for Ruby 1.8.7 has been dropped since 2014-01-27. It's supposed to work with Ruby 1.9.1, but no test is performed yet.

### Why Anidown?
Flash is really dirty. So does Flash players on Linux. Gnash is known to have problems with almost every website in China, and the *proprietary* ~~Adobe Flash Player~~ runs really slow. Conclusion: Linux doesn't really support Flash. (or more precisely, Flash doesn't support Linux)

But most online video hosting websites in China rely on Flash...

So why don't we download all the videos and view them offline with our favorite media players? Grab Anidown and start enjoying the latest animes now!

### Why not Dantalian.rb?
I wrote a Ruby script called dantalian.rb, which does pretty much the same thing as Anidown does. However, it is very user-friendly (translation: bloated and inefficient), so I decided to replace it with Anidown, which is much slimmer.

Don't worry. I'm working on dantalian.rb to turn it into a frontend of Anidown. So you can get your easy-to-use interactive downloader back within a month or so.

### This repo has multiple mirrors
Anidown was originally hosted on [Github](https://github.com/sheep0x/anidown). But sadly, the mercurial-git package (Wheezy) doesn't work for me, so I have to put up with different SCMs. The local repo is managed by Mercurial, and Git is only used as a tool to upload/download files to/from Github. This weird approach not only required extra labors, but also made the commit history nonsense.

Now the repo has moved to [Bitbucket](https://bitbucket.org/sheep0x/anidown), but the Github repo is still updated for the conveniece of some people.

If you want to contribute, Mercurial+Bitbucket is of course recommended. However, if you don't want to set up a Bitbucket account just to submit a few changes, you can:

1. upload your code to Github and send me a pull request, or

2. send me a patch

and I'll merge your changes manually.
