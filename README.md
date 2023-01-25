# com.castsoftware.uc.asmzos


The Extension should be used for Mainframe COBOL and Assembler language. The extension has been developed to parse the Assembler Program and create the link with ASM program or COBOL program called.
The Extension implements customer metrics using CAST Universal Analyzer.

See wiki for complete description


Changes needs to be done in console configuration files.

Code-scanner-config.xml

        <discoverer extensionId="com.castsoftware.uc.asmzos" dmtId="asmzosfilediscoverer"
                    fileExtensions=".asm;.ASM;.mlc;.MLC;.asmacro;.ASMACRO;" label="ASMZOS"/>
        <discoverer extensionId="com.castsoftware.uc.easytrieve" dmtId="esyzosfilediscoverer"
                    fileExtensions=".ESY;.MAC;.esy;.mac" label="Easy"/>
        <discoverer extensionId="com.castsoftware.labs.ctl.link" dmtId="ctlzosfilediscoverer"
                    fileExtensions=".CTL;.ctl;.ndm;.NDM;" label="CTL"/>


dependencies-matrix.xml

   <technology symbol="ASMZOS" type="language">
        <allow symbol="SQL"/>
    </technology>

    <technology symbol="CTL" type="language">
        <allow symbol="SQL"/>
    </technology>

    <technology symbol="Easy" type="language">
        <allow symbol="SQL"/>
    </technology>


