ICC
===

Run an Infant Controlled Categorization (ICC) study in Matlab with minimal configuration. This is useful for developmental psychologists who want to examine infants' categorization abilities using a novelty preference procedure.

# How to use ICC

## Download ICC

* Download icc.m and the example "artecat" study folder
* Create a folder in your MATLAB directory and place these files inside of it
* Add this folder to your list of MATLAB paths

## Create a new study

* Copy the example study folder, "artecat", into a subfolder of your main ICC directory
* Modify `config.txt` with the configuration options for the new study
* Modify the stimuli in the `stimuli` sub-folder.

## Run a session

* Load MATLAB
* Type `icc` in the command prompt
* Select your new study folder and click "Open"
* Follow on-screen prompts (e.g., enter the experimenter's name, infant's subject code, age, etc.)
* Code the infant's looking using the LeftArrow (for a right look), RightArrow (for a left look), and DownArrow (for a center look)
* A log for the session will be created in the `logs` sub-folder
* A session file (with looking time results, participant details, and session metadata) will be created in the `sessions` sub-folder

# Author

Written by [Brock Ferguson](http://www.brockferguson.com). I am a researcher at Northwestern University study infant conceptual development and language acquisition.