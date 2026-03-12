// ImageJ Macro: Batch HSB Mask Analysis with Preview and CSV Output
//McKenna Burns 2025

// Prompt for input directory and output directory
inputDir = getDirectory("Select the INPUT folder");                       
outputDir = getDirectory("Select the OUTPUT folder");

// Corrected error-checking for empty paths... 
if (inputDir == "" || lengthOf(inputDir) == 0 || outputDir == "" || lengthOf(outputDir) == 0) 
    exit("Macro canceled: No folder selected.");

// Prompt for adding results filename suffix
suffix = getString("Enter a suffix for the results file:", "mysuffix");   
if (suffix == "") exit("No suffix entered, macro canceled.");

// Prompt for determining threshold ranges for three masks using a dialog
Dialog.create("Threshold Ranges for 3 Masks");
Dialog.addMessage("Enter HSB min/max for each mask:");
Dialog.addMessage("Mask 1:");
Dialog.addNumber("Hue min", 0); Dialog.addNumber("Hue max", 255);
Dialog.addNumber("Sat min", 0); Dialog.addNumber("Sat max", 255);
Dialog.addNumber("Bri min", 0); Dialog.addNumber("Bri max", 255);
Dialog.addMessage("Mask 2:");
Dialog.addNumber("Hue min", 0); Dialog.addNumber("Hue max", 255);
Dialog.addNumber("Sat min", 0); Dialog.addNumber("Sat max", 255);
Dialog.addNumber("Bri min", 0); Dialog.addNumber("Bri max", 255);
Dialog.addMessage("Mask 3:");
Dialog.addNumber("Hue min", 0); Dialog.addNumber("Hue max", 255);
Dialog.addNumber("Sat min", 0); Dialog.addNumber("Sat max", 255);
Dialog.addNumber("Bri min", 0); Dialog.addNumber("Bri max", 255);
Dialog.show();

// Read threshold values
h1_min = Dialog.getNumber(); h1_max = Dialog.getNumber();
s1_min = Dialog.getNumber(); s1_max = Dialog.getNumber();
b1_min = Dialog.getNumber(); b1_max = Dialog.getNumber();
h2_min = Dialog.getNumber(); h2_max = Dialog.getNumber();
s2_min = Dialog.getNumber(); s2_max = Dialog.getNumber();
b2_min = Dialog.getNumber(); b2_max = Dialog.getNumber();
h3_min = Dialog.getNumber(); h3_max = Dialog.getNumber();
s3_min = Dialog.getNumber(); s3_max = Dialog.getNumber();
b3_min = Dialog.getNumber(); b3_max = Dialog.getNumber();

// Find the first .tif image in the input directory for preview
//fileList = getFileList(inputDir);
//firstFile = "";
//for (i=0; i<fileList.length; i++) {
//    if (!File.isDirectory(inputDir + fileList[i]) && endsWith(fileList[i], ".tif")) {
//        firstFile = fileList[i];
//        break;
//    }
//}
//if (firstFile == "") exit("No .tif images found in the input folder.");

// ** PREVIEW Stage... Super annoying; can delete **
//open(inputDir + firstFile);
//origTitle = getTitle();
//run("Duplicate...", "title=Preview"); 
//run("HSB Stack");
//run("Stack to Images");
//selectWindow("Hue"); rename("Hue");
//selectWindow("Saturation"); rename("Sat");
//selectWindow("Brightness"); rename("Bri");

//if (isOpen(origTitle)) { selectWindow(origTitle); close(); }

//selectWindow("Preview");
//run("RGB Color");

// Mask 1 Preview Overlay
//selectWindow("Hue"); run("Duplicate...", "title=hMask");
//setThreshold(h1_min, h1_max); run("Convert to Mask");
//selectWindow("Sat"); run("Duplicate...", "title=sMask");
//setThreshold(s1_min, s1_max); run("Convert to Mask");
//selectWindow("Bri"); run("Duplicate...", "title=bMask");
//setThreshold(b1_min, b1_max); run("Convert to Mask");

//imageCalculator("AND create", "hMask","sMask");
//imageCalculator("AND create", "Result of hMask","bMask");

//selectWindow("Result of Result of hMask"); rename("Mask1");

//selectWindow("Mask1");
//setThreshold(255, 255); run("Create Selection");
//if (selectionType() != "None") {
//    selectWindow("Preview");
//    setForegroundColor(255, 0, 0);
//    run("Fill");
//}
//selectWindow("Mask1"); close();

// Show Preview and wait for user confirmation
//selectWindow("Preview");
//waitForUser("Preview Overlay", "Overlay preview shown. Click OK to continue batch processing.");
//close();

// ** Batch Processing Stage **
outPath = outputDir + "results_" + suffix + ".csv";
if (File.exists(outPath)) File.delete(outPath);
File.saveString("Image,TotalPixels,Mask1_Count,Mask2_Count,Mask3_Count\n", outPath);

fileList = getFileList(inputDir);

for (i = 0; i < fileList.length; i++) {
    name = fileList[i];
    if (File.isDirectory(inputDir + name) || !endsWith(name, ".tif"))
        continue;

    path = inputDir + name;
    open(path);
    title = getTitle();
    width = getWidth(); height = getHeight();
    totalPix = width * height;

    // Convert to HSB and split
    run("HSB Stack");
    run("Stack to Images");
    selectWindow("Hue"); rename("Hue_" + i);
    selectWindow("Saturation"); rename("Sat_" + i);
    selectWindow("Brightness"); rename("Bri_" + i);
    if (isOpen(title)) close(title);

    // MASK 1
    selectWindow("Hue_" + i); run("Duplicate...", "title=h1_" + i);
    setThreshold(h1_min, h1_max); run("Convert to Mask");
    selectWindow("Sat_" + i); run("Duplicate...", "title=s1_" + i);
    setThreshold(s1_min, s1_max); run("Convert to Mask");
    selectWindow("Bri_" + i); run("Duplicate...", "title=b1_" + i);
    setThreshold(b1_min, b1_max); run("Convert to Mask");

    imageCalculator("AND create", "h1_" + i, "s1_" + i); rename("m1_temp_" + i);
    imageCalculator("AND create", "m1_temp_" + i, "b1_" + i); rename("Mask1_" + i);

    selectWindow("Mask1_" + i);
    values = newArray(256); counts = newArray(256);
    getHistogram(values, counts, 256);
    count1 = counts[255];
    close();

    // MASK 2
    selectWindow("Hue_" + i); run("Duplicate...", "title=h2_" + i);
    setThreshold(h2_min, h2_max); run("Convert to Mask");
    selectWindow("Sat_" + i); run("Duplicate...", "title=s2_" + i);
    setThreshold(s2_min, s2_max); run("Convert to Mask");
    selectWindow("Bri_" + i); run("Duplicate...", "title=b2_" + i);
    setThreshold(b2_min, b2_max); run("Convert to Mask");

    imageCalculator("AND create", "h2_" + i, "s2_" + i); rename("m2_temp_" + i);
    imageCalculator("AND create", "m2_temp_" + i, "b2_" + i); rename("Mask2_" + i);

    selectWindow("Mask2_" + i);
    values = newArray(256); counts = newArray(256);
    getHistogram(values, counts, 256);
    count2 = counts[255];
    close();

    // MASK 3
    selectWindow("Hue_" + i); run("Duplicate...", "title=h3_" + i);
    setThreshold(h3_min, h3_max); run("Convert to Mask");
    selectWindow("Sat_" + i); run("Duplicate...", "title=s3_" + i);
    setThreshold(s3_min, s3_max); run("Convert to Mask");
    selectWindow("Bri_" + i); run("Duplicate...", "title=b3_" + i);
    setThreshold(b3_min, b3_max); run("Convert to Mask");

    imageCalculator("AND create", "h3_" + i, "s3_" + i); rename("m3_temp_" + i);
    imageCalculator("AND create", "m3_temp_" + i, "b3_" + i); rename("Mask3_" + i);

    selectWindow("Mask3_" + i);
    values = newArray(256); counts = newArray(256);
    getHistogram(values, counts, 256);
    count3 = counts[255];
    close();

    // Append results
    line = name + "," + totalPix + "," + count1 + "," + count2 + "," + count3 + "\n";
    File.append(line, outPath);

    // Close base channels
    if (isOpen("Hue_" + i)) close("Hue_" + i);
    if (isOpen("Sat_" + i)) close("Sat_" + i);
    if (isOpen("Bri_" + i)) close("Bri_" + i);
}
