Anidown
=======

About
-----
Anidown is a simple anime batch downloader for Chinese Linuxers. (For those who don't know, ``anime'' basically means ``Japanese cartoon''.)

Anidown finds sources of animes by parsing search results from Soku.com. Then it queries Flvcd.com to get URLs of each episode and downloads them.

Anidown is a complete rewrite of my previous works, and it is under heavy development, so please be patient if it doesn't have feature XXX.

Finally, if you're willing to help improve Anidown, please do so. Any contribution will be much appreciated.

Goal
----
* simple
* fast (not achieved yet)
* Unixy

Legal issues
------------
Anidown is licensed under Apache License, Version 2.0.

The source code is completely legal. However, its usage might **NOT** be. Please consult a lawyer if you are not living in Mainland China.

Why Anidown?
------------
Flash is really dirty. So does Flash players on Linux. Gnash is known to have problems with almost every website in China, and the *proprietary* ~~Adobe Flash Player~~ runs really slow. Conclusion: Linux don't really support Flash.

So why don't we download all the videos and view it with our favorite media players? Grab Anidown and start enjoying the latest animes now!

Why not Dantalian.rb?
---------------------
I wrote a Ruby script called dantalian.rb, which does pretty much the same thing as Anidown do. It is very user-friendly (translation: bloated and inefficient), so I decide to replace it with Anidown, which is much slimmer.

Don't worry, I'm working on dantalian.rb to turn it into a frontend of Anidown. So you can get your easy-to-use interactive downloader back within a month or so.

Why the repo contains Mercurial files?
--------------------------------------
Sadly, the mercurial-git package (Wheezy) doesn't work so well for me, so I have to put up with different SCMs.

This repo is actually a Mercurial repo, and Git is only used as a tool to upload/download files to/from Github. That's why the Github repo also includes the .hg directory and the .hgignore file.

Since the Git repo doesn't keep track of the actual commits, it is not supposed to be used as a collaborative tool. However, this script is so simple that patches works just fine.

If you know how to fix the mercurial-git bug or have any good suggestions about a better workaround, please tell me. And sorry again for the inconvenience.
