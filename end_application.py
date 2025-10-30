import cast_upgrade_1_6_23 # @UnusedImport
from cast.application import ApplicationLevelExtension, create_link, open_source_file, Bookmark, ReferenceFinder
import logging
from builtins import len
from collections import defaultdict
import re
import traceback, sys

class endapp(ApplicationLevelExtension):

    def __init__(self):
        
        ApplicationLevelExtension.__init__(self)
        self.cics_load_regex = '\s+EXEC\s+CICS\s+LOAD\s+PROGRAM\s*\([\'|\"]*([\w]+)+[\'|\"]*'
        self.cobol_comments = '^.{6}[*/].*\n'

    def end_application(self, application):
        
        logging.info("Running code at the end of an application")
        
        logging.info("****** Searching for CAST_COBOL_ProgramPrototype")
        cobol_unknown_list = []
        cobol_list = []
        ideal_list = []
        pli_list = []
        call_to_programs_list = defaultdict(list)
        self.links = []
        asm_list = defaultdict(list)
        asm_macro_list = defaultdict(list)
        self.links = []


        cics_load_access = ReferenceFinder()
        cics_load_access.add_pattern("comments", before="", element=self.cobol_comments, after="")
        cics_load_access.add_pattern("cicsload", before="", element=self.cics_load_regex, after="")


        ## Cobol to Assembler Calls. This also covers JCL to Assembler Calls        
        for cobol_unknown in application.objects().has_type('CAST_COBOL_ProgramPrototype'):
            #logging.debug ("Cobol CAST_COBOL_ProgramPrototype found: {}".format(cobol_unknown.get_name()))
            cobol_unknown_list.append(cobol_unknown)
        logging.info("****** Number of CAST_COBOL_ProgramPrototype {}".format(str(len(cobol_unknown_list))))
        
        logging.info("****** Searching for ASMZOSProgram")

        for asm_pgm in application.objects().has_type('ASMZOSProgram'):
            #logging.debug ("ASMZOSProgram found: {}".format(asm_pgm.get_name()))
            asm_list[asm_pgm.get_name()].append(asm_pgm)
        logging.info("****** Number of ASMZOSProgram {}".format(str(len(asm_list))))
        
        ## Assembler to Cobol Calls.         
        for cobol_known in application.objects().has_type('CAST_COBOL_SavedProgram'):
            #logging.debug ("Cobol CAST_COBOL_SavedProgram found: {}".format(cobol_known.get_name()))
            cobol_list.append(cobol_known)
        logging.info("****** Number of CAST_COBOL_SavedProgram {}".format(str(len(cobol_list))))

        try:
            for pli_main in application.objects().has_type('PLIMainProcedure'):
                #logging.info("PLIMainProcedure found: {}".format(pli_main.get_name()))
                pli_list.append(pli_main)
        except KeyError:
            pass

        logging.info("****** Number of PLIMainProcedure {}".format(str(len(pli_list))))

        try:
            for ideal_pgm in application.objects().has_type('ideal_program'):
                #logging.info("Ideal Programs found: {}".format(ideal_pgm.get_name()))
                ideal_list[ideal_pgm.get_name()].append(ideal_pgm)
        except KeyError:
            pass
                
        logging.info("****** Number of Ideal Programs {}".format(str(len(ideal_list))))


        try:
            for call_to_pgm in application.objects().has_type('CallTo_program'):
                #logging.info("call_to_pgm found: {}".format(call_to_pgm.get_name()))
                call_to_programs_list[call_to_pgm.get_name()].append(call_to_pgm)
        except KeyError:
            pass
                
        logging.info("****** Number of CallTo_program {}".format(str(len(call_to_programs_list))))

        
        # matching by name : if CAST_COBOL_SavedProgram has same name as CallTo_program, they are the same object
        for keyvalue in call_to_programs_list.items():
            call_to_pgm = keyvalue[0]
            call_to_pgm_objects = keyvalue[1]
            
            for call_to_pgm_obj in call_to_pgm_objects:
                for cobol_known in cobol_list:
                    if cobol_known.get_name() == call_to_pgm:
                        # we have a match
                        link = ('matchLink', call_to_pgm_obj,cobol_known)
                        self.links.append(link)
           
                for ideal_pgm in ideal_list:
                    if ideal_pgm.get_name() == call_to_pgm:
                        # we have a match
                        link = ('matchLink', call_to_pgm_obj,ideal_pgm)
                        self.links.append(link)
           
                for pli_pgm in pli_list:
                    if pli_pgm.get_name() == call_to_pgm:
                        # we have a match
                        link = ('matchLink', call_to_pgm_obj,pli_pgm)
                        self.links.append(link)
                
                for asm_pgm in asm_list[call_to_pgm]:
                    # we have a match
                    link = ('matchLink', call_to_pgm_obj,asm_pgm)
                    self.links.append(link)
                

         # matching by name : if CAST_COBOL_ProgramPrototype has same name as Assembler Program, they are the same object
        nbLinkCreated = 0
        for asm_l in asm_list.values():
            for asm_pgm in asm_l:
                for cobol_unknown in cobol_unknown_list:
                    if cobol_unknown.get_name() == asm_pgm.get_name():
                        # we have a match
                        link = ('matchLink', cobol_unknown, asm_pgm)
                        self.links.append(link)

                   
        for link in self.links:
            create_link(*link)
            nbLinkCreated +=1

        logging.info("****** Number of Links created : {}".format(str(nbLinkCreated)))
        
 
        # Link Assembler program to Assembler Macro
        
        for asm_macro in application.objects().has_type('ASM_MACRO'):
            #logging.debug ("ASM_MACRO found: {}".format(asm_macro.get_name()))
            asm_macro_list[asm_macro.get_name().strip()].append(asm_macro)
            
        logging.info("****** Number of ASM Macro {}".format(str(len(asm_macro_list))))
        

        asm_macro_regex = r'^(?!\*)(?:[\w@#$]+)*\s+([\w@#$]+)+\s*'
        self.prg_regex = re.compile(asm_macro_regex, re.IGNORECASE)
        self.lineNb = 0
        
        ## Scan through all the Assembler Programs and find the reference of Assembler Macro
        nb_links_to_ast_and_mlc = 0
        for asm in application.get_files(['sourceFile']):
            # check if file is analyzed source code, or if it generated (Unknown)
            #logging.info("CTL is " + str(CTL))
            program_name = ""

            if not asm.get_path():
                continue

            if not (asm.get_path().lower().endswith('.asm')) and not (asm.get_path().lower().endswith('.mlc')):
                continue

            self.lineNb = 0

            macro_access = ReferenceFinder()
            macro_access.add_pattern("macro", before="", element=asm_macro_regex, after="")
            macro_access.add_pattern("comments", before="", element=asm_macro_regex, after="")
     
            references = []
            references += [reference for reference in macro_access.find_references_in_file(asm)]
            logging.info("coucou debug nb_references: " + str(len(references)) + " for asm file" + asm.get_path())
            for reference in references:
                asm_macro_name = reference.value.strip()
                if len(asm_macro_name.split()) >= 2:
                    asm_macro_name = asm_macro_name.split()[1]

                for macroObjs in asm_macro_list[asm_macro_name.strip()]:
                    for macroObj in macroObjs:
                        nb_links_to_ast_and_mlc+=1
                        self.links.append(('callLink', reference.object, macroObj, reference.bookmark))

        logging.info("****** Number of links from .asm and .mlc files: ".format(str(nb_links_to_ast_and_mlc)))

        for o in application.objects().has_type('CAST_COBOL_Program'):
  
            #logging.info(str(o.get_path()))
            # check if file is analyzed source code, or if it generated (Unknown)
            if not o.get_path():
                continue

            references = []
            references += [reference for reference in cics_load_access.find_references_in_file(o)]
            logging.info("coucou debug nb_references: " + str(len(references)) + " for current program " + o.get_path())
            #logging.info("references is " + str(references))
            for reference in references:
                if  reference.pattern_name=='comments':
                    pass
                else:
                    caller_obj = reference
                    asm_program_name = reference.value.strip().split("(")[1].replace("'","").replace('"','').strip()
                    for asm_pgm in asm_list[asm_program_name]:

                        link = ('callLink', reference.object,asm_pgm,reference.bookmark)
                        self.links.append(link)

        logging.info("****** Total number of links {}".format(str(len(self.links))))
        
        for link in self.links:
            try:
                l = create_link(*link)
                #logging.info(" Created Link->" + str(link))
            except Exception as e:
                logging.info('Exception while creating link ' + str(link) + ' error: ' + str(e))
                exception_type, value, tb = sys.exc_info()
                logging.warning('exception_type = ' + str(exception_type) + ' Error message = ' + str(e))
                traceback_str = ''.join(traceback.format_tb(tb))
                logging.warning(traceback_str)    

    