Required:

-- JDK needed. To install JDK if you don't already have one,
     -- go to http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
     -- accept the cookie dialogue
     -- In the section headed "Java SE Development Kit 8u91"  click the checkbox next to 'Accept License Agreement'
     -- then click on the link 'jdk-8u91-macosx-x64.dmg'
     -- after the .dmg file is downloaded, if it doesn't open automatically double click on it and follow the installation instructions
     -- when the installation is finished, in a Finder window you'll see the DMG listed under 'Devices' in the left column: just click on the arrow to unmount it.


Put the KWIC folder on your Desktop.


To run any of the scripts, use the command line inside a terminal window.

     -- in a Finder window, under Applications -> Utilities click on Terminal.app
     -- type: cd ~/Desktop/KWIC/
     -- hit ENTER
     -- type: ls -al
     -- hit ENTER; now you can see all the contents of the /KWIC/ directory
     -- now use the "cd" command again to go into the desired directory. Eg for a semi-diplomatic index, the command would be "cd Semi_Dip_KWIC_HTML/"
     -- to generate an index, run one of the commands below and hit ENTER

Command to run script without using the stopwords list:

  ./makeKWIC.sh -i temp1/[filename] -o temp2/[filename]_KWIClist.html

Eg: ./makeKWIC.sh -i temp1/1_Fr_20125.xml -o temp2/1_Fr_20125_KWIClist.html


Command to run script with stop words turned on:

  ./makeKWIC.sh -i temp1/[filename] -o temp2/[filename]_KWIClist.html -l yes

Eg:  ./makeKWIC.sh -i temp1/1_Fr_20125.xml -o temp2/1_Fr_20125_KWIClist.html -l yes
