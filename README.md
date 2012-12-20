# README #
Dec 19, 2012

## Description ##
The goal of this project is to create generative prints for a fundraiser auction in support of [Alias Dance Project](http://www.aliasdanceproject.com/). The current plan is to write image matching algorithms that will recreate a target image from the subsections of other images. To use an analogy, the target image is the archetype/subject and the images being sampled are the media/paint. The output would be the painting while rules being applied to determine which subsections are used could be called the brush (but that's stretching it).

## Interacting with the sketch ##
The current verion of the sketch is simply a way to visualize and test the first (primitive) matching system. I'll be adding other matching systems such as average colour matching and spectrum biased HSV histogram matching. How far I get will depend on complexity, available time and most importantly, I may like some of the early renders and stop there.

Currently, interaction is:

- press 'S' to save a screen cap.

## Running it yourself ##
The sketch currently runs under Processing v2.0b7. Processing is available from Processing.org

The sketch uses Processing and the amazing [Toxiclibs](http://toxiclibs.org) from [Karsten Schmidt, aka toxi](http://postspectacular.com/). While [Kyle Phillips](http://haptic-data.com), (@hapticdata) is creating a port of [Toxiclibs for javascript](http://haptic-data.com/toxiclibsjs/), the sketch uses colour functions that haven't been ported yet.

Stephen Boyd

@sspboyd