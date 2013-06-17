ICC
===

Run an Infant Controlled Categorization (ICC) study in Matlab with minimal configuration. This is useful for developmental psychologists who want to examine infants' categorization abilities using a novelty preference procedure.

# How to use ICC

## Download ICC

* Download icc.m and the example "artecat" study folder
* Create a folder in your Matlab directory and place these files inside of it
* Add this folder to your list of Matlab paths

## Create a new study

* Copy the example study folder, "artecat", into a subfolder of your main ICC directory
* Modify `config.txt` with the configuration options for the new study
* Modify the stimuli in the `stimuli` sub-folder.

## Run a session

* Load Matlab
* Type `icc` in the command prompt
* Select your new study folder and click "Open"
* Follow on-screen prompts (e.g., enter the experimenter's name, infant's subject code, age, etc.)
* Code the infant's looking using the LeftArrow (for a right look), RightArrow (for a left look), and DownArrow (for a center look)
* A log for the session will be created in the `logs` sub-folder
* A session file (with looking time results, participant details, and session metadata) will be created in the `sessions` sub-folder

# Author, Copyright, & Citation

All original code written by and copyright (2013), [Brock Ferguson](http://www.brockferguson.com). I am a researcher at Northwestern University study infant conceptual development and language acquisition.

You can cite this software using:

> Ferguson, B. (2013). Infant-Controlled Categorization (ICC) for Matlab. Retrieved from https://github.com/brockf/ICC.

This code is **completely dependent** on the [PsychToolbox library for Matlab](http://psychtoolbox.org/PsychtoolboxCredits). You should absolutely cite them if you use this library:

> Bernstein, M. (2002). 10 tips on writing the living Web. A List Apart: For People Who Make Websites, 149. Retrieved from http://www.alistapart.com/articles/writeliving
