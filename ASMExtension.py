"""
reference documentation 
- https://www.ibm.com/docs/en/SSENW6_1.6.0/pdf/asmr1024_pdf.pdf

"""

import cast_upgrade_1_6_23
import cast.analysers.ua
from cast.analysers import log, CustomObject, create_link, Bookmark, external_link
from cast.application import open_source_file
import os, sys, traceback, re, binascii
import cast
from collections import OrderedDict, defaultdict
from pathlib import Path
from light_parser.splitter import Splitter


class Variant:
    
    # file with end-exec, new format
    with_end_exec = 1
    # file without end-exec, old format
    without_end_exec = 2


class ASMExtension(cast.analysers.ua.Extension):

    def __init__(self):
        
        self.nbLinksCreated = 0
        self.extensions = ['.asm','.mlc']
        self.extensions1 = ['.asmacro']
        self.active = True
        self.nbpgmCreated = 0
        self.nbmacroCreated = 0
        self.first_sql_lineNb = ""
        self.links = []
        self.temp_links = []  
        self.asm_unknown_prog_main_list = defaultdict(list)  
        self.guidsToNotDuplicate = OrderedDict()
        self.nbasmSRCScanned = 0
        self.comment_regex = "^(\*).*"
        self.macro_check = r'^(?!\*).*(MACRO)+\s*'
        self.program_call_regex =  '[ \t]+((CALL[ \t]+([\w-]+))+|PROGRAM\(\'([\w-]+))'

        self.asm_regexes = [re.compile(p) for p in [self.program_call_regex]]

        # macros by name
        self.macros = defaultdict(list)

        # list of pair (file, program)
        self.programs = list()

        self.query_guid_number = defaultdict(int)

    def start_analysis(self):
        log.info(" Running extension code at the start of the analysis")
        try:
            options = cast.analysers.get_ua_options() #@UndefinedVariable
            self.active = False
            if 'Assembler' in options:
                self.active = True
            else:
                self.active = False
        except Exception as e:
            pass # unit test

    @staticmethod
    def __create_object(self, name, typ, parent,filepath, bookmark=None):
        obj = None

        fullname = self.create_guid(typ, name) + '/' + filepath + '/'
        
        try:
            if name != "":
                obj = CustomObject()                    
                obj.set_name(name)
                obj.set_fullname(name)
                obj.set_type(typ)
                obj.set_parent(parent)
                obj.set_guid(fullname)
                
                obj.save()
                #log.info('Saved object: ' + str(name) + ' type:' + str(typ))
                #log.info("bookmark is " + str(bookmark))
                if bookmark != None and (typ != 'ASMZOSProgram' and typ != 'ASM_MACRO'):
                    link = ('callLink', parent, obj, bookmark)
                    self.links.append(link)
                
                if bookmark != None:    
                    obj.save_position(bookmark)

            return obj
        except Exception as e:
            log.warning('Exception while saving object ' + str(name) + ' error: ' + str(e))
            exception_type, value, tb = sys.exc_info()
            log.warning('exception_type = ' + str(exception_type) + ' Error message = ' + str(e))
            traceback_str = ''.join(traceback.format_tb(tb))
            log.warning(traceback_str)
            
        return None
    

    def start_file(self,file):
    
        self.temp_links = []
        self.links = []
        
        if not self.active:
            return # no need to do anything
        
        filepath = file.get_path().lower()

        log.info('Scanning ' + filepath)
        
        #_, <- because we're discarding the first part of the splitext
        _, ext = os.path.splitext(filepath)
        
        #log.info("ext is" + str(ext))
        #log.info("file is " + str(file))
        
        if ext.lower() in self.extensions1:
            """
            Scan one Assembler Macro file
            """
            filepath = file.get_path()
    
            #log.info("Parsing Macro file %s..." % file)
            self.project = file.get_project()
            
            self.guid_data = Path(file.get_path()).name
    
            filepath = file.get_path()
            self.nbasmSRCScanned += 1
            #initialization
            line_number = 0

            caller_object = None
            self.call_to_program_obj = None
    
            content = ""
    
            with open_source_file(file.get_path()) as srcfile1:
                content = srcfile1.read()
    
            with open_source_file(file.get_path()) as srcfile1:
                #log.info("srcfile1" + str(srcfile1))             
                mylist = [line.rstrip('\n') for line in srcfile1]
                firstline = mylist[0]
                self.firstlineNb = 1
                self.lastlineNb = len(mylist)
                obj_name = firstline.split("(")[1].split(")")[0]
                self.start_pos = 1
                self.last_pos = 1
                #log.info("file is " + str(file))
                asmzos_defn_obj_bookmark = Bookmark(file, 0, -1, (self.lastlineNb-1), -1)
                #log.info("asmzos_defn_obj_bookmark is-->" + str(asmzos_defn_obj_bookmark))
                
                asmzos_defn_obj = self.__create_object(self, obj_name, "ASM_MACRO", file, filepath, asmzos_defn_obj_bookmark)
                self.macros[obj_name].append(asmzos_defn_obj)
                self.nbmacroCreated += 1
                
            crc = binascii.crc32(content.encode()) 
            asmzos_defn_obj.save_property('checksum.CodeOnlyChecksum', crc % 2147483648)
                 
            
        elif ext.lower() in self.extensions:
            """
            Scan one Assembler  program file
            """
            filepath = file.get_path()
    
            #log.info("Parsing file %s..." % file)
            self.project = file.get_project()
            
            self.guid_data = Path(file.get_path()).name
    
            file = file
            filepath = file.get_path()
            self.nbasmSRCScanned += 1
            #initialization
            line_number = 0
            
            caller_object = None
            self.call_to_program_obj = None
    
            content = ""
            asmzos_defn_obj = None
            
            with open_source_file(file.get_path()) as srcfile1:
                content = srcfile1.read()
    
            with open_source_file(file.get_path()) as srcfile1:
                #log.info("srcfile1" + str(srcfile1))             
                mylist = [line.rstrip('\n') for line in srcfile1]
                firstline = mylist[0]
                self.firstlineNb = 1
                self.lastlineNb = len(mylist)
                obj_name = firstline.split("(")[1].split(")")[0]
                self.start_pos = 1
                self.last_pos = 1
                asmzos_defn_obj_bookmark = Bookmark(file, 0, -1, (self.lastlineNb-1), -1)
                firstcode_line = "'"
                
                line_nb = 0
                macro_linenum = 0
                uncommented_line = 0
                macro_regex = re.compile(self.macro_check)
                
                asm_regexes = [macro_regex]
                #log.info("macro_regex is " + str(macro_regex))
                # the main object we will create (Program of Macro)
                asmzos_defn_obj = None         
                for line in mylist:
                    line_nb += 1
                    if not line.startswith('*') and line_nb > 1:
                        uncommented_line += 1
                        myOnDict = [compiled_regex for compiled_regex in asm_regexes if re.match(compiled_regex,line)]
                        #log.info("myOnDict is " + str(myOnDict))
                        if myOnDict:
                            #log.info("uncommented_line is " + str(uncommented_line))
                            if uncommented_line == self.firstlineNb:
                                #log.info(" myOnDict[0] is " + str(myOnDict[0]))
                                search_text = myOnDict[0].search(line)
                                #log.info("search_text" + str(search_text))
                                asmzos_defn_obj = self.__create_object(self,obj_name, "ASM_MACRO", file, filepath, asmzos_defn_obj_bookmark)
                                self.macros[obj_name].append(asmzos_defn_obj)
                                self.nbpgmCreated += 1
                        else:
                            if asmzos_defn_obj is None:
                                asmzos_defn_obj = self.__create_object(self,obj_name, "ASMZOSProgram", file, filepath, asmzos_defn_obj_bookmark)
                                self.programs.append((file, asmzos_defn_obj))
                                self.nbpgmCreated += 1
                
                #log.info(" obj_name object created is " + str(obj_name))
                caller_object = asmzos_defn_obj
             
            crc = binascii.crc32(content.encode()) 
            asmzos_defn_obj.save_property('checksum.CodeOnlyChecksum', crc % 2147483648)

            seen_end_exec = False
            
            self.caller_bookmark_new = None
            with open_source_file(file.get_path()) as srcfile:
                #log.info(" Processing file is " + str(srcfile))
                obj = None
    
                for line in srcfile:

                    line_number +=1
                    if line_number > 1 and not line.startswith("END_PROGRAM") and not line.startswith("*"):
                    #if not line.startswith("BEGIN_PROGRAM") and not line.startswith("END_PROGRAM"):
                        processed_line = "N"
                        for regexp in self.asm_regexes:
                            asm_search_text = re.search(regexp,line)
                            only_regex = regexp.pattern
                            #log.info("asm_search_text is " + str(asm_search_text))
                            #log.info("line is " + str(line))
                            if asm_search_text != None: 
                                if only_regex == self.program_call_regex:
                                    #len_groups = len(asm_search_text.groups())
                                    start_end_pos = asm_search_text.span()
                                    
                                    start_pos = start_end_pos[0]
                                    end_pos = start_end_pos[1]
                                    
                                    called_program_name = ""
                                    if len(asm_search_text.group(0).split()) > 1:
                                        called_program_name = asm_search_text.group(0).split()[1]
                                    else:
                                        called_program_name = asm_search_text.group(0).split("'")[1].split("'")[0]
                                    
                                    if called_program_name != "":
                                    #called_program_name = asm_search_text.group(len_groups-1).strip().split()[0]
                                        self.caller_bookmark_new = Bookmark(file, line_number , start_pos, line_number, end_pos)
                                        if called_program_name not in self.asm_unknown_prog_main_list.keys():
                                            try:
                                                obj = self.__create_object(self,called_program_name, "CallTo_program", caller_object,filepath, self.caller_bookmark_new)
                                                self.asm_unknown_prog_main_list[called_program_name].append(obj)
                                            except:
                                                pass
                                        else:
                                            for key, val in self.asm_unknown_prog_main_list.items():
                                                if key == called_program_name:
                                                    link = ('callLink', caller_object, val, self.caller_bookmark_new)
                                                    self.links.append(link)
                    
                        if 'END-EXEC' in line:
                            seen_end_exec = True
                        
                        
            # there are several variants for assembler program
            # EXEC SQL without END-EXEC
            # EXEC SQL with END-EXEC
            if seen_end_exec:
                variant = Variant.with_end_exec
            else:
                variant = Variant.without_end_exec
            
            # store the information on the object
            asmzos_defn_obj.variant = variant
                            
                            
        for link in self.links:
            linktype, caller_object, callee_object, nbookmark = link
            if 'cast' in str(type(caller_object)) and 'cast' in str(type(callee_object)):
                if link not in self.temp_links:
                    self.temp_links.append(link) 
        
        for link in self.temp_links:
            self.nbLinksCreated += 1
            #log.info(' Link created is ' + str(link))
            create_link(*link)          

    def end_analysis(self):
        if not self.active:
            return
        
        log.info('Second pass')
        # will split text with blanks keeping them as elements
        # for example 
        # splitter.split('NAME COMMAND REMARK')
        # -> ['NAME', ' ', 'COMMAND', ' ', REMARK']
        # splitter.split(' \t COMMAND')
        # -> ' \t ', 'COMMAND']
        splitter = Splitter([])
        
        # second pass, linking
        for file, program in self.programs:
            
            try:
                log.info('Scanning ' + file.get_path())
                with open_source_file(file.get_path()) as content:
                    
                    exec_sql_regex = re.compile('^\s+EXEC\s+SQL\s+')
                    inside_exec_sql = False
                    current_exec_sql_text = None
                    current_exec_sql_begin_line = None
                    current_exec_sql_begin_column = None
                    
                    line_number = 0
                    for line in content:
                        line_number += 1

                        if line.startswith(('*', '.*')):
                            # comment
                            continue
                        if not line:
                            # empty line
                            continue
                        
                        tokens = splitter.split(line)
                        # search for macro call
                        if len(tokens) > 1:

                            begin_column = len(tokens[0])
                            macro_name = None
                            
                            # first case no label
                            # ' MYMACRO PARAMETERS...'
                            if tokens[0].isspace():
                                macro_name = tokens[1]
                                
                            elif len(tokens) > 2:
                                # second case a label 
                                # 'LABEL MYMACRO PARAMETERS...'
                                macro_name = tokens[2]
                                begin_column += len(tokens[1]) + 1
                            
                            if macro_name and macro_name in self.macros:
                                end_column = begin_column + len(macro_name)
                                
                                bookmark = Bookmark(file, line_number, begin_column, line_number, end_column)
                                
                                for macro in self.macros[macro_name]:
                                    create_link("callLink", program, macro, bookmark)
                        
                        # exec sql
                        # two syntaxes
                        # EXEC SQL ... END-EXEC no continuation line simple
                        # EXEC SQL ... an X at column 72 for continuation, no END-EXEC and garbage after column 73
                        # we know which one through the variant
                        if inside_exec_sql:
                            if program.variant == Variant.with_end_exec:
                                # search for end-exec in the same line
                                if 'END-EXEC' in line:
                                    text_fragment = line.split('END-EXEC')[0]
                                    current_exec_sql_text += text_fragment
                                    
                                    bookmark = Bookmark(file, 
                                                        current_exec_sql_begin_line, 
                                                        current_exec_sql_begin_column+1,
                                                        line_number,
                                                        len(text_fragment))
                                    
                                    self.create_sql_query(program, current_exec_sql_text, bookmark)
                                    # end of exec sql
                                    current_exec_sql_text = None
                                    inside_exec_sql = False
                                else:
                                    current_exec_sql_text += line
                            else:
                                text_fragment = line[:71]
                                current_exec_sql_text += text_fragment
                                if len(line) > 71 and line[71] in ('X', '*'):
                                    # multi line exec sql formated code
                                    current_exec_sql_text += '\n'
                                else:
                                    # formated code
                                    
                                    bookmark = Bookmark(file, 
                                                        current_exec_sql_begin_line, 
                                                        current_exec_sql_begin_column+1,
                                                        line_number,
                                                        len(text_fragment))
                                    
                                    self.create_sql_query(program, current_exec_sql_text, bookmark)
                                    # end of exec sql
                                    current_exec_sql_text = None
                                    inside_exec_sql = False
                            
                        elif re.match(exec_sql_regex, line):

                            inside_exec_sql = True
                            current_exec_sql_begin_line = line_number
                            current_exec_sql_begin_column = line.find('SQL') + 3
                            
                            if program.variant == Variant.with_end_exec:
                                
                                # search for end-exec in the same line
                                if 'END-EXEC' in line:
                                    current_exec_sql_text = line[current_exec_sql_begin_column:].split('END-EXEC')[0]

                                    bookmark = Bookmark(file, 
                                                        current_exec_sql_begin_line, 
                                                        current_exec_sql_begin_column+1,
                                                        line_number,
                                                        current_exec_sql_begin_column+len(current_exec_sql_text))

                                    self.create_sql_query(program, current_exec_sql_text, bookmark)
                                    # end of exec sql
                                    current_exec_sql_text = None
                                    inside_exec_sql = False
                                else:
                                    current_exec_sql_text = line[current_exec_sql_begin_column:]
                            else:
                                # columned format
                                text_fragment = line[:71]
                                current_exec_sql_text = text_fragment[current_exec_sql_begin_column:]
                                if line[71] in ('X', '*'):
                                    # multi line exec sql formated code
                                    current_exec_sql_text += '\n'
                                else:
                                    # mono line exec sql formated code
                                    bookmark = Bookmark(file, 
                                                        current_exec_sql_begin_line, 
                                                        current_exec_sql_begin_column+1,
                                                        line_number,
                                                        current_exec_sql_begin_column+len(text_fragment))
                                    
                                    self.create_sql_query(program, current_exec_sql_text, bookmark)
                                    # end of exec sql
                                    current_exec_sql_text = None
                                    inside_exec_sql = False
                                
            except:
                log.warning(traceback.format_exc())
        
        log.info(" Statistics for AIA ")
        log.info("*****************************************************************")
        log.info(" Number of Source files Scanned " + str(self.nbasmSRCScanned))
        log.info(" Number of Links Created " + str(self.nbLinksCreated))
        log.info(" Total ASM Program Objects Created  -- > " + str(self.nbpgmCreated))
        log.info("*****************************************************************")

    def create_sql_query(self, program, text, bookmark):
        
        # name of the query is restricted to 4 words
        name = get_sql_query_name(text)
        
        guid = '2043008?' + bookmark.get_file().get_path() + '.' + name
        
        if guid in self.query_guid_number:
            self.query_guid_number[guid] += 1
            guid = guid + '_' + str(self.query_guid_number[guid])
        else:
            self.query_guid_number[guid] = 0
        
        o = CustomObject()
        o.set_type('ASMZOSSQLQuery')
        o.set_name(name)
        o.set_guid(guid)
        o.set_parent(program)
        o.save()
        
        o.save_position(bookmark)
        o.save_property('CAST_SQL_MetricableQuery.sqlQuery', text)
        
        # link from program to query
        link_bookmark = Bookmark(bookmark.get_file(),
                                 bookmark.get_begin_line(),
                                 1,
                                 bookmark.get_begin_line(),
                                 bookmark.get_begin_column(),
                                 )
        
        create_link('callLink', program, o, link_bookmark)

    def create_guid(self, objectType, objectName):
        
        if not type(objectName) is str:
            return objectType + '/' + objectName.name
        else:
            return objectType + '/' + objectName


def get_sql_query_name(sql_query_text):
    # normalization of query name
    # see 
    # https://cast-products.atlassian.net/wiki/spaces/PDTGNL/pages/1902756/Rules+and+Best+practices+for+Modelisation#RulesandBestpracticesforModelisation-NamingofQueries
    max_words = 4
    sql_query_text = sql_query_text.strip()
    if sql_query_text.upper().startswith(('EXEC', 'EXECUTE')):
        # we don't show parameters in the name for procedure calls
        max_words = 2
    truncated_sql = sql_query_text
    
    splitted = sql_query_text.split()
    if len(splitted) > max_words:
        truncated_sql = " ".join(splitted[0:max_words])
        
    return truncated_sql


