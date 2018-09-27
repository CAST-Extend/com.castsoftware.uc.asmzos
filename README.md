# com.castsoftware.uc.asmzos
# 1 	Description
The Extension should be used for Mainframe COBOL and Assembler language. The extension has been developed to parse the Assembler Program and create the link with ASM program or COBOL program called.
The Extension implements customer metrics using CAST Universal Analyzer.
# 1.1	Version
 The table below indicates the current version of the Extension and history of versions.
Version	Date	Name
 1.0.0	September, 2018  	 com.castsoftware.uc.asmzos.1.0.0
# 1.2	Use cases
The Extension is covering the following use cases: 
•	Link Call from ASM Program to ASM Program or Cobol Program
Technology Involved	Techno type 	Quality 
•	ASSEMBLER
•	COBOL	Legacy	  
 

 
# 2	Compatibility
# 2.1	CAST AIP compatibility
The following table gives the list of CAST AIP configurations where the Extension has been implemented: 
CAST AIP release 	Has previously worked 	In Version of Extension
8.3.5	 	Current
# 2.2	Other technology compatibility
The Extension has been implemented in standard CAST AIP installation and platform, without other products or components using Universal Analyzer Framework.
# 2.3	Recent implementation
Not available
 
# 3	Prerequisites & Installation
# 3.1	Prerequisites
The following table gives the complete list of technical prerequisites to be met before installing the Extension:
The following table gives the complete list of technical prerequisites to be met before installing the Extension:
An installation of any compatible release of CAST AIP (see table above)
# 3.2	Installation instructions
# 3.2.1	Download the extension from CAST Extension Downloader 
The CAST Extension Downloader is provided along with the CAST Installation
 

 
# 3.2.2	Install the Extension 
Before to install the Extension, you have to create and customize it as showed into CAST Software Documentation "Cookbooks Working with CAST AIP Extensions".
After customization the Extension installation is available directly from CAST Server Manager. 
•	Open CAST Server Manger
•	Create new or existing triplet schema 
•	Select the Extension to install it on schema
•	Click to proceed to install
 
 


# 4	How to use
# 4.1	Features and Environment
The extension has been implemented with a pre-proces step for Assembler Source code Programs and the custom dependencies using Refine Target to Cobol Program and Reference Pattern to crate the link ASM Programs to ASM or COB Programs. 
# 4.2	Extension of technologies cover for UA
The Extension is extending technology coverage for CAST operations as below specified. 
Code Type	Required Extension	Mandatory/Optional	Comments
Assembler	*.asm
*.ASM	Mandatory	Assembler source code
Cobol	*.CBL
*.COB	Optional	Cobol source code 
# 4.3	Pre-proces (launch.bat)
The  pre-process is a batch (launch.bat) defined in prepro extension subfolder for example like  “C:\ProgramData\CAST\CAST\Extensions\com.castsoftware.uc.asmzos.1.0.0\Configuration\Languages\ASMZOS”. 

 

The batch uses as input information the application Deploy folder, LISA folder and LOGS folder. It copy the ASM source code files in LISA folder inserting at the top of source code the tag “BEGIN_PROGRAM(program name)” and at the both the tag “END_PROGRAM”. 
These two tags are used to define to UA the boby of source code parsed by UA ASMZOS Extension. 

This is the program before the tags.

 

This is the program after the tags.

  

The batch creates a log file (with final suffix LOG_PREPROCES) in log root directory like this “AU_ASM_60598-20180926-18321_LOG_PREPROCES.TXT”.
# 4.4	Refine pattern and reference pattern
In Application Dependencies Tab must be defined a custom dependency between source (UA Assembler) and target (Cobol) with a reference pattern to create the link. To do this you have to 
o	Define custom dependencies Source / Target
o	Define Target Refine  & Define Reference Pattern 
# 4.5	Define dependencies with Refine pattern
Create custom dependencies Source as Universal (UA Assembler) and Target as Mainframe. 
 
Define Refine Target for Mainframe filter Analysis Unit Mainframe and Object Type Cobol Program and Nested Cobol Program 
 
 
# 5	What the results expected
Once the analysis has completed the following objects will be displayed in CAST Enlighten.
o	Object Name : FS1I2007
o	Object Type : ASMZOS Program
 
# 5.1	Analysis strategy
The Cast AI Administrator needs to know the technologies and the languages involved to customize the metrics and the extensions. 
# 5.2	Extension of Technology Coverage, with UA/UI
There is not specific requirement about packaging and delivering source code of specific technology with the custom Extension.
# 5.3	Documentation history
To be define.
 

# 6	Known limitations
Nothing specific.
# 6.1	Limitations
No additional information is available
# 6.2	Possible evolution
No additional information is available

# 7	Components present in the package
o	ASMZOSLanguagePattern.xml
o	The XML file used of UA ASMZOS Extension to parse the Assembler Source Code to find the CALL to other programs 
o	ASMZOSMetaModel.xml
o	The XML metamodel associated to the UA ASMZOS Extension
o	Launch.bat
o	The  pre-process batch used to copy the Assembler files to analyse and to insert the tags to define the body of source to parse 
o	TestCases folder
o	A folder with test case files used to develop the UA ASMZOS Extension 
