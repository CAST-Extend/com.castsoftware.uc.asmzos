# com.castsoftware.uc.asmzos


The Extension should be used for Mainframe COBOL and Assembler language. The extension has been developed to parse the Assembler Program and create the link with ASM program or COBOL program called.
The Extension implements customer metrics using CAST Universal Analyzer.

See wiki for complete description


Changes needs to be done in console configuration files.

Code-scanner-config.xml

	<discoverer extensionId="com.castsoftware.uc.asmzos" dmtId="asmzosfilediscoverer"
                fileExtensions=".asm;.ASM;.mlc;.MLC;.asmacro;.ASMACRO;" label="ASM zOS Files"/>
    <discoverer extensionId="com.castsoftware.labs.ctl.link" dmtId="ctlzosfilediscoverer"
                fileExtensions=".CTL;.ctl;.ndm;.NDM;" label="CTL zOS Files"/>
    <discoverer extensionId="com.castsoftware.labs.rexx" dmtId="rexxzosfilediscoverer"
                fileExtensions=".REXX;.rexx;" label="REXX zOS Files"/>    
    <discoverer extensionId="com.castsoftware.labs.focus" dmtId="focuszosfilediscoverer"
                fileExtensions=".FEX;.MAS;.FOC;.fex;.mas;.foc;" label="focus zOS Files"/>    
    <discoverer extensionId="com.castsoftware.uc.easytrieve" dmtId="esyzosfilediscoverer"
                fileExtensions=".ESY;.MAC;.esy;.mac;" label="ESY zOS Files"/>    
    <discoverer extensionId="com.castsoftware.labs.zos.basesas" dmtId="saszosfilediscoverer"
                fileExtensions=".sas;.SAS;" label="SAS zOS Files"/> 


dependencies-matrix.xml

	<technology symbol="Mainframe Control Parms" type="language">
        <allow symbol="SQL"/>
    </technology>
    <technology symbol="Assembler" type="language">
        <allow symbol="SQL"/>
    </technology>
    <technology symbol="Rexx Language" type="language">
        <allow symbol="SQL"/>
    </technology> 
    <technology symbol="Easytrieve Plus Language" type="language">
        <allow symbol="SQL"/>
    </technology>
    <technology symbol="FOCUS Language" type="language">
        <allow symbol="SQL"/>
    </technology>

    <technology symbol="BaseSAS" type="language">
        <allow symbol="SQL"/>
    </technology>

