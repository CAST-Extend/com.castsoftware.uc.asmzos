# com.castsoftware.uc.asmzos


The Extension should be used for Mainframe COBOL and Assembler language. The extension has been developed to parse the Assembler Program and create the link with ASM program or COBOL program called.
The Extension implements customer metrics using CAST Universal Analyzer.

See wiki for complete description


code-scanner-config.xml

                  <discoverer extensionId="com.castsoftware.uc.asmzos" dmtId="asmzosfilediscoverer"
                    fileExtensions=".asm;.ASM;.mlc;.MLC;.asmacro;.ASMACRO;" label="ASMZOS"/>

dependencies-matrix.xml

    <technology symbol="ASMZOS" type="language">
        <allow symbol="SQL"/>
    </technology>
    

