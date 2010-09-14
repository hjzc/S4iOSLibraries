


S4iOSLibrary Quick Start Developer Guide

Michael Papp

September 9, 2010



Overview

	The S4iOSLib library is designed to be both a platform (framework, if you will) for iOS development, as well as a 'container' for utilities that should be useful to all Apple developers.  The library's APIs are designed to convey the same architectural patterns utilized by Apple's iOS/ObjectiveC-based platform.  It relies heavily on protocols and delegates, and offers singletons when appropriate for Manager-type classes.  The main goal, however, is to provide a robust and stable set of utilities that will allow developers to focus on creating great new features for iOS, and not reinvent the millions of little wheels that underly almost every application.  This library will be continually updated to the latest version of iOS, and track improvements in the XCode IDE as well.  The basics:

	• Supports iOS versions from 3.1.2 up to 4.1.
	• Supports both Simulator and Device
	• Free for use in both open source and commercial projects (under Mozilla MPL license)
	• Attribution appreciated but not required
	• The project is currently a one-person endeavor and likely to stay that way;  suggestions are gladly taken and contributions welcomed
	• The project utilizes a select set of other open source projects.  They are selected for great code and an active development community.
	   An equally important criteria has been to select projects that are licensed under terms compatible with the Mozilla MPL license;  these
	   projects are listed in section (4) below



1. Source repository and project layout

	The S4iOSLib library is currently hosted in a Git repository stored stored on Github.  A copy may be obtained by pasting the following command in a Terminal window (given that you have navigated to the location where you want the source code to reside on your local disk):

git clone git://github.com/mikekppp/S4iOSLibraries.git

While there is nothing special about the particular arrangement of the directories, the S4iOSLib project uses relative paths to find the other projects.  Hence, changing the directory hierarchy will break these relative paths.  This is not an admonition to keep the current structure intact, but rather advice that if you change the directory structure (locally or in SCM), you will need to go into each project (including the application projects) and make sure all the symbolic links and relative paths are adjusted to compensate for any change you might make.

Directory layouts within each project are self-explanatory.  In brief, the S4iOSLib project contains the following directories:

	• Classes - contains source code
	• dist - a directory containing headers, resources, and the static library to be used in other projects.  The contents of this directory is managed by build scripts within each project.  DO NOT modify the contents yourself.  Directions are given below for modifying this directory.  DO NOT link other projects into the "build" directory, please use this one instead.
	• Resources - contains graphics files (.png, .jpg, etc.), IB files, and any files you intend to build into an application outside of source files.
	• Vendor - this directory contains 3rd-party libraries and source code.  The Facebook Connect library is an example.  In general, the directories in the Vendor folder are created by performing a command (using the appropriate SCM tool) to checkout or clone a copy of the source from the host repository.  If you ever want to get the latest copy of a 3rd-party library, just use Terminal to cd into that directory and use the SCM-appropriate command to update the copy.  More on this later.



2. Building the projects

	The S4iOSLib dist directory is checked in to Git to hold files that are not changed during the build process.  The bulk of the files in the dist directory are either created during the build process, or the latest versions are copied from the appropriate places during a build cycle.

As described above, the end results of building the S4iOSLib project is to place a set of "distribution" files into the dist directory.  Everything needed to use the static library is placed in the dist directory, including headers, resources, and a special binary of the static library.  Here is an important note:  the libS4iOSLib.a static library binary is not simply copied from the builds directory - it is actually built by a post-processing script in the project.  This is important for a few reasons, but in this context it is relevant to explain why the project must be built in a certain way.  Specifically, the libS4iOSLib.a static library is built to contain both a debug and release image of the code.  This is done using the "lipo" tool in the post-processing script.  Lipo can create a combo static library as long as the two 'starter' libraries have different processor architectures.  In other words, you can only build a library (using lipo) that has an x86 version and an ARM v6/v7 version.  By default, the post-processing script takes the x86-debug-simulator library and merges it with the ARM-release-device library.  This generally fits most needs *unless* you want to debug on the device.  It is recommended that you build a debug version for the device and link the application's project to that binary in your local copy of the application project.

Now you know most of the basics needed to build the libraries.  If you are familiar with the workings of XCode 3.x, the instructions below give you the general idea of what you need to do;  if you are new or uncertain about how XCode works, please follow these instructions exactly:

	1. In the build target drop down menu (top left in the Project Window), select "iOS <LATEST VERSION>  Simulator" and then select (in the same drop down) "Debug".  Go to the build menu and select "Clean all targets".  Click OK on the resulting modal dialog.
	2. Now go back to the build target drop down menu and select "iOS <LATEST VERSION> Device" and then select "Release" in the same menu. Go to the build menu and select "Clean all targets".  Click OK on the resulting modal dialog
	3. Select Build from the "Build" menu (or type cmd-B).
	4. If everything builds OK, go back to the build target drop down menu and select "iOS <LATEST VERSION>  Simulator" and then select (in the same drop down) "Debug".
	5. Select Build from the "Build" menu (or type cmd-B).
	6. If the compile/link cycle for both builds succeeds, there will be a fresh set of files in the dist directory, including a brand new libS4iOSLib.a file.

There are no "hidden" errors with the build scripts.  Compile and/or linker errors appear as they normally would in the build results window.  Errors in running the scripts ALSO appear in the build results window.  For those knowledgeable in the ways of XCode, and particularly for those more knowledgeable than I regarding embedded build scripts, the build process described above could certainly be streamlined.  However, I wanted to keep things simple and as build scripts get more complex, they become a development area in and of themselves.  Note, I will have instructions on building the library on XCode 4.x when it is released.  For that matter, the project itself will be moved to XCode 4.x once it is released.

If you want to add, remove, or change the location of files in the dist directory, open the 'targets' icon on the lefthand side of the project window in XCode.  Double-
click the "run script" item that appears first in the list.  This is the pre-processing script and removes ("cleans") the dist directory prior to each build.  If a build ever fails, the dist directory will be devoid of files (although the internal directories remain).  If you add, remove, or move files, make sure this script is updated to address new or removed files, or point to new directories.  You will see another "run script" build phase at the very end of the tasks within the target icon.  This is the post-processing script.  If you add, remove, or move files that should be placed in the dist directory, modify this script.  The script starts by verifying that both a successful simulator and device library builds exist.  If not, nothing happens.  If so, then it calls the lipo tool to build a single, combined static library with both x86 and ARM code inside.  Next, the script copies files from the internal directories in the project into either the Headers directory (.h files, of course) or the Resources directory (just about everything else).  Add or remove the copy commands as appropriate to the change(s) you have made.  Note that these are basically shell scripts, and command calls are
 basically Unix commands.  Hence, you have to follow the rules for these commands as to what can, or cannot, be copied.  For example, .bundle files are actually 
directories to the cp command - therefore, you cannot cp a .bundle 'file.'  It must be treated as a directory.



3. Adding S4iOSLib to your application

	Once the S4iOSLib static library is built, it is easy to incorporate in your iOS application.  Open your project file and 'add' a new group to your project ("S4iOSLib", for example) in the lefthand pane of the project.  Then ctrl-or-right click on this new group, navigate to the 'dist' directory for the respective project, and select all the items in the directory.  In the resulting File Add dialog box, make sure you do NOT copy files into the project (keep them in their original locations) and check the 'make smart folders' option.  NOTE:  The Resources directory in dist contains a subdirectory (icons) with a large number of open source icons available for you to use in your application.  If you do not want to add all of these icons to your project, add only the Headers directory and libS4iOSLib.a file to your project.  Then you can pick and choose the resources you want to add to your application from Resources.  If you do not use ANY of the UI functionality in S4iOSLib, then you do not need any of the files in the Resources directory.

Next, we need to add frameworks and system libraries used by both the application and the static S4iOSLib which is now linked with the project.  Ctrl or right-click on the Frameworks icon in the left pane of the Project Window.  Choose "Add.. Existing Frameworks" from the resulting context menu, and select the following libraries:



When you have selected all the frameworks/libraries listed above, click the "add" button in the dialog.

Finally, go to the "Project" menu and select the "Edit Project Settings" menu item.  Perform the following steps in the Build tab for the project :


	•	In the Architectures section:
	⁃	Make sure the Base SDK is "iOS <LATEST VERSION>  Device"
	⁃	Make sure the build active architecture only checkbox is UNCHECKED.

	•	In the Deployment section:
	⁃	(Optional) S4iOSLib supports all Targeted device family settings
	⁃	(Optional) S4iOSLib supports all iPhone OS deployment target settings of iOS 3.1.2 and above 

	•	In the Linking section:
	⁃	Add the following flags to the Other Linker Flags item (without the quotes):    "-ObjC -all_load"

	•	In the Search Paths section:
	⁃	Add the following flags to the Header Search Paths item (without the quotes):    "$SDKROOT/usr/include/libxml2"



3. "Third party" open source projects used in this library

	The author is grateful to the individual developers and the open source community in general for their efforts in creating/maintaining the following projects used in S4iOSLibrary:

	•	Erica Sadun's NSFileManager-Utilities project <http://github.com/erica/NSFileManager-Utilities>
	•	Erica Sadun's uidevice-extension project <http://github.com/erica/uidevice-extension>
	•	Stig Brautaset's json-framework project <http://github.com/stig/json-framework>
	•	Lloyd Hilaiel's yajl project <http://github.com/lloyd/yajl>





