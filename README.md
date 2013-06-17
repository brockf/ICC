ICC
===

Run an Infant Controlled Categorization (ICC) study in Matlab with minimal configuration. This is useful for developmental psychologists who want to examine infants' categorization abilities using a novelty preference procedure.

Infants are familiarized to 8 images of objects in a given category (e.g., 8 dogs; you control the stimuli) and, at test, see a new object belonging to this familiar category and a new object from an unfamiliar category. Their novelty preference at test is measured as evidence of categorization during.

An attention getter is used at the beginning of each session and before the test phase. You can also configure it to appear if the infant looks less than the required amount of time during a single familiarization trial, to re-engage the participant.

You can configure the task to have a pre-test assessment of infants' preference between the two objects at test. You can also add a pre-familiarization movie. By default, there is a left/right calibration video that plays at the very beginning of the experiment.

## How to use ICC

### Download ICC

* Download icc.m and the example "artecat" study folder
* Create a folder in your Matlab directory and place these files inside of it
* Add this folder to your list of Matlab paths

### Create a new study

* Copy the example study folder, "artecat", into a subfolder of your main ICC directory
* Modify `config.txt` with the configuration options for the new study using Excel. Save as a tab-delimited text file.
* Modify the stimuli in the `stimuli` sub-folder.

### Run a session

* Load Matlab
* Type `icc` in the command prompt
* Select your new study folder and click "Open"
* Follow on-screen prompts (e.g., enter the experimenter's name, infant's subject code, age, etc.)
* Code the infant's looking using the LeftArrow (for a right look), RightArrow (for a left look), and DownArrow (for a center look). Press the corresponding key when the infant is looking in that direction on the screen, and release the key when the baby stops looking.
* A log for the session will be created in the `logs` sub-folder
* A session file (with looking time results, participant details, and session metadata) will be created in the `sessions` sub-folder

## Author, Copyright, & Citation

All original code written by and copyright (2013), [Brock Ferguson](http://www.brockferguson.com). I am a researcher at Northwestern University study infant conceptual development and language acquisition.

You can cite this software using:

> Ferguson, B. (2013). Infant-Controlled Categorization (ICC) for Matlab. Retrieved from https://github.com/brockf/ICC.

This code is **completely dependent** on the [PsychToolbox library for Matlab](http://psychtoolbox.org/PsychtoolboxCredits). You should absolutely cite them if you use this library:

> Brainard, D. H. (1997) The Psychophysics Toolbox, Spatial Vision 10:433-436.

> Pelli, D. G. (1997) The VideoToolbox software for visual psychophysics: Transforming numbers into movies, Spatial Vision 10:437-442.

> Kleiner M, Brainard D, Pelli D, 2007, "What's new in Psychtoolbox-3?" Perception 36 ECVP Abstract Supplement.
