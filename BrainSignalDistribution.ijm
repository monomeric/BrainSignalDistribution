/* *********************************************************************************
Copyright 2019 Aymeric Fouquier d'Hérouël, Luxembourg Centre for Systems Biomedicine

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
********************************************************************************** */

// prepare message and control box
msg1="This macro quantifies fluorescence signal distributions in left and right brain "+"\n"+
     "hemispheres from confocal sections. Required input is a reference nuclear signal"+"\n"+
     "(e.g. DAPI) and a corresponding image of the fluorescence distribution to be    "+"\n"+
     "assessed. Brain position and rotation are detected automatically, but may fail  "+"\n"+
     "if:                                                                             "+"\n"+
     "     - strong background signal or bright artefacts are present                 "+"\n"+
     "     - brain slice is incomplete or too close to image boundaries               "+"\n \n"+
     "  Settings:"
     
msg2="\n In the next two file dialogs, select first the REFERENCE then the SIGNAL."

Dialog.create("Brain Signal Distribution");
Dialog.addMessage(msg1);
Dialog.addChoice("         Reference thresholding",newArray("Mean","Moments"),"Mean");
Dialog.addToSameRow;
Dialog.addNumber("Dilatation steps",10)
Dialog.addCheckbox("Specify center of mass",0);
Dialog.addToSameRow;
Dialog.addCheckbox("Draw saggital (major) axis",0);
Dialog.addMessage(msg2);
Dialog.show;
method = Dialog.getChoice;
center = Dialog.getCheckbox;
axis = Dialog.getCheckbox;
dilatesteps = Dialog.getNumber;

// read data and display

/* BEGIN OF FILE DIALOG BLOCK: Uncomment the next two lines for file dialog */
file_dapi=File.openDialog("Select the DAPI reference");
run("Open...","open=[&file_dapi]");
/* END OF FILE DIALOG BLOCK */

/* !!! COMMENT OUT AUTOMATIC READING WHEN FILE DIALOG IS ACTIVE !!! */
//open("<PATH TO DAPI SIGNAL IMAGE>");

run("Enhance Contrast", "saturated=0.35");
rename("DAPI");

/* BEGIN OF FILE DIALOG BLOCK: Uncomment the next two lines for file dialog */
file_gfp=File.openDialog("Select the GFP signal"); 
run("Open...","open=[&file_gfp]");
/* END OF FILE DIALOG BLOCK */

/* !!! COMMENT OUT AUTOMATIC READING WHEN FILE DIALOG IS ACTIVE !!! */
//open("<PATH TO GFP SIGNAL IMAGE>");

run("Enhance Contrast", "saturated=0.35");
rename("GFP");

//dir=File.directory;

run("Duplicate...","title=[Mask]");
run("Tile");

run("Set Measurements...", "center fit decimal=3");
selectWindow("DAPI");
setAutoThreshold(method+" dark");
setOption("BlackBackground", true);
run("Convert to Mask");
for (i=0;i<dilatesteps;i++) {
	run("Dilate");
}
run("Fill Holes");
run("Analyze Particles...", "size=1000000-Infinity display exclude clear add");
//run("Invert");
//roiManager("Select", 0);
//run("Clear Outside");
//roiManager("Measure");
selectWindow("GFP");
//run("Invert");
roiManager("Select", 0);
getSelectionBounds(left,top,width,height)
//getStatistics(area,mean,min,max,std,histogram);
//getDimensions(width,height,channels,slices,frames);

run("Clear Outside");
selectWindow("Mask")
roiManager("Select", 0);
run("Clear Outside");
//setThreshold(16,255);
setAutoThreshold("Moments dark");
run("Convert to Mask");
imageCalculator("Multiply create 32-bit","GFP","Mask");
run("Tile");
selectWindow("Result of GFP");
//run("Divide...", "value=255"); // IJ seems to scale properly in newer versions, no need to divide
run("8-bit");

// get image parameters from ellipse fit ...
x0=getResult("XM",0);
y0=getResult("YM",0);
phi=getResult("Angle",0);

// ... or manually
if (center) {
	waitForUser("Draw a small circle at the center of mass.\nAdd the shape to the ROI Manager (press t).");
	run("Measure");
	x0=getResult("XM",0);
	y0=getResult("YM",0);
}
if (axis) {
	waitForUser("Draw a straight line along the saggital axis.\nAdd the line to the ROI Manager (press t).");
	run("Measure");
	phi=getResult("Angle",0);
}

// useful definitions
setBackgroundColor(0,0,0);
sin_phi=sin(phi*PI/180);
cos_phi=cos(phi*PI/180);

//print("\\Clear")
L=0;
R=0;
start = getTime;
for (y=top;y<top+height;y++) {
	for (x=left;x<left+width;x++) {
		a=(x-x0)*cos_phi-(y-y0)*sin_phi;
//  DEBUG:
//	b=(x-x0)*sin_phi+(y-y0)*cos_phi;
		p=getPixel(x,y);
		if (a>0) {
			R=R+p;
			setPixel(x,y,p+50);
		} else {
			L=L+p;
			setPixel(x,y,p+150);
		}
//    DEBUG:
//		print("cor: "+x+", "+y);
//		print("pos: "+a+", "+b);
//		print("dat: "+getPixel(x,y)+" "+phi);
	}
}
print((getTime-start)/1000+"s");

roiManager("Select", 0);
setForegroundColor(255,0,0);
run("Draw", "slice");
run("Fit Ellipse");

setResult("L",0,L);
setResult("R",0,R);
setResult("LogRatio",0,log(R/L)/log(2));

//close("DAPI");
//close("GFP");
//run("Add Image...", "image=Mask x=0 y=0 opacity=50");
//close("Result of GFP");
//close("Mask");
roiManager("Delete");
