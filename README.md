This repository contains a number of sketches I have written in Processing (java based programming environment).
To run them visit processing.org and download Processing. Once you have gained some familiarity with the environment. Copy sketch folders to your processing sketch folder and they will be ready to execute.


DPRGLineFollowingCourseEditor - Interactive Editor for producing SVG (Scalable Vector Files) suitable for producing line following courses as currently used by Dallas Personal Robotics Group (www.dprg.org).

LineFollowingCourseInterpreter - Experimental tile description language interpreter. The language uses terse mnemonic instructions to describe line following course geometry. The output is screen or SVG file. Sample datafile (.LFC extension) contains language description and program that generates the DPRG Challenge Line Following Contest Course. The  DPRGLineFollowingCourseEditor is recommended over this program / language as it uses an explicit tile location and orientation format much simpler to manipulate.

LineFollowingCourseSimpleDemo - Illustrates some of the techniques used to build the line following course editor.

TransformDemo2D - Illustrates the geometric transforms used building the line following course editor.

LineTracker_WorldCrunbs - Illustrates detection of a line with a forward looking line sensor, then tracking it with respect to the robot using cookie crumbs. The forward (real) sensor detects the crumbs then places them in world coordinates which a virtual sensor on the robot detects and provides input to steering system.

LineTracker_WithPathGen2 - Simulation illustrating an idealized version of DPRG Challenge Course wiht the LineTracker robot simulation. This simulation relies on a path generated using the .LFC (Line Following Course) language used by the LineFollowingCourseInterpreter.
Thus, the LFC interpreter is included in this program. The path generation portion uses cookie crumbs versus SVG output. That is each feature in the Challenge Course generates a series of crumbs.  Hard turns are replaced with smooth turns... 


--------------------------------------------------------------------------------------
Additional Notes on DPRGLineFollowingCourseEditor

Interactive Processing Application designed to create Line Following Contest Courses as used by Dallas Personal Robotics Group (dprg.org).

Course descriptions are loaded from/ saved to Line Following Tile (.LFT) files and also can be exported to SVG (Scalable Vector Format) for use with a drawing program such as Inkscape. Inkscape can export very large PNG files suitable for banner printing. The banner printing service I use is stickersbanners.com. As of Apr 2019, they charge $1.49/sq ft for printed vinyl banner with no additional shipping charge. The current DPRG Challenge Course was printed using stickersbanners.com

The Novice/Advanced and Challenge Line Following Courses were designed by Doug Paradis with later revisions by Carl Ott. This program has not been used to date to create any courses and some modifications and additions may be required.. Make sure to verify correctness of any pattern (SVG file) produced.

This application (sketch) requires Processing a java based IDE. See processing.org for information on downloading and setting up Processing. Once installed the DPRGLineFollowingCourseEditor folder and its contents can be copied to the Processing sketches folder then loaded and executed from there. Processing does provide the ability to export a binary executable file, that relies on an copy of its runtime library ~ 170 MB
