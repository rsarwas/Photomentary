#  Photomentary

A photo documentary of our life.  This multiplatform (but mostly tvOS) app will read
photo files off our our private Network Storage device (using SMB) and display them
on screen for a limited amount of time before presenting another photo.  The photos
are captioned (typically) with the name of the folder that the photo is in.  Our
folders are typically named with a "date - activity" format, so they make a good
description.

This app will only work when it has network access to the NAS, which typically
means that it is on the same router as the NAS, as it is typically private.

Photo files can be in any format that the underlying platform understands. JPEG, 
TIFF, PNG, and HEIC have all been tested, but others are also supported. See 
[UIImage](https://developer.apple.com/documentation/uikit/uiimage) and/or
[NSImage](https://developer.apple.com/documentation/appkit/nsimage) for details.

There is a list of photo files included in the bundle.  It needs to be update (see
photos.py for details) whenever the photos on the NAS change.  The app is hard coded
with the network path and SMB credentials.  The app will need to be recompiled
and redistributed if any of these items change.

The app allows the following user interactions

## Using

### Play/Pause
The user to pause/resume the automatic advancement to the next photo. 

* tvOS - Press the play/pause button on the siri remote.
* macOS - Press the play/pause button on the touchbar or function keys
* iOS - TBD

### Move Manually
You can also manually advance or go back to previous photos.  You can do this while
playing, but pause first if you do not want the app to unexpectedly advance on you.
Only a limited number (50 for now) photos are being cached for backing up. If you
resume play after moving back to a previous photo it will replay all photo from
that point (it will not start showing new photos until it has replayed all the photos
you backed up through).

* tvOS -   'it works better if youap back/forward throught the photos manually. For tvOS tap (not click)
the left or right side of the track pad on the siri remote to go back/forward
respectively.
* macOS - TBD
* iOS - TBD

### Adjust Delay
The amount of time a photo is displayed before automatically advancing to the next
photo can be adjusted.

* tvOS - TBD
* macOS - TBD
* iOS - TBD

## To Do

* Add UI to adjust the delay interval
* Save the delay interval to the user's preferences
* Finish the UI for all platforms
* Turn off the screen saver when the app is running (user configurable?)
* Load the file list from the Network server (rather than bundling it)
* Consider doing network transfer and image creation on a background thread.
  It is currently done asyncronously in chuncks, and seems to not be impacting
  the UI.
* The caption should be at bottom of screen and not bottom of main image. This
  is important for really wide (pano) photos where image is centered vertically
  and the caption does not need to overlap the image
* Resume currently starts the time then waits to change the image. It should
  load the next image immediately, then start the time.
* Consider Connect/disconnect to the SMB server in class init/deinit; Currently
  done on every image load, although it seems to be cached, because subsequent
  connects are fast.  Needs testing. Note: it takes about 34 seconds for the first
  connect to complete (there are about 14 connects pending before the connection
  succeeds.)
* Need App Icon
* Need splash screen
* Need initial image (cached in bundle) while we wait for the first network image.
* It currently takes several seconds to start downloading the first image.  What's
  happening, and how can it happen sooner?
* Save the changes to AMSMB2 library and request pull to upstream
* Modify the AMSMB2 library to simplify use (XCFramework or Swift Package). May
  need to separate the libsmb C library from the swift code.
* Write Tests
* Check Memory usage
* Consider compressing the photo list (4.9 vs. 0.5 MB) to speed up loading.
