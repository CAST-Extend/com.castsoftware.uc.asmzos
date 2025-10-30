import cast.analysers.ua
from cast.analysers import log, CustomObject, create_link, Bookmark, external_link
import os
import sys
import traceback
import cast
from collections import OrderedDict
import random
from pathlib import Path
import re
from _collections import defaultdict
import binascii


class ASMExtension(cast.analysers.ua.Extension):

    def __init__(self):
        
        self.nbLinksCreated = 0
        self.extensions = ['.asm','.mlc']
        self.extensions1 = ['.asmacro']
        self.active = False
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
        self.exec_sql_call_regex =  '\s+EXEC\s+SQL\s+'
        self.sql_query = ""
        self.exec_sql_found = "N"
        #self.asm_regexes = [self.comment_regex,
        #                    self.program_call_regex]                             ###Access Link
        # 

        self.asm_regexes = [ re.compile(p) for p in [ self.program_call_regex,self.exec_sql_call_regex]]

    def start_analysis(self):
        log.info(" Running extension code at the start of the analysis")
        try:
            options = cast.analysers.get_ua_options() #@UndefinedVariable
            if 'Assembler' not in options:
                self.active = False
            else:
                self.active = True
                #self.extensions.extend(options['ASMZOS'].extensions)
                #self.extensions1.extend(options['ASMZOS'].extensions)
        except Exception as e:
            exception_type, value, tb = sys.exc_info()
            log.warning('exception_type = ' + str(exception_type) + ' Error message = ' + str(e))
            log.warning(traceback_str)
    


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
        log.info("Running code at the Startfile")
        ## test mode only
        #self.active = True
        
        if not self.active:
            return # no need to do anything
        
        filepath = file.get_path().lower()
        #_, <- because we're discarding the first part of the splitext
        _, ext = os.path.splitext(filepath)
        
        #log.info("ext is" + str(ext))
        #log.info("file is " + str(file))
        
        if ext.lower() in self.extensions1:
            self.filepath = file.get_path()
    
            #log.info("Parsing Macro file %s..." % file)
            self.project = file.get_project()
            
            self.guid_data = Path(file.get_path()).name
    
            self.file = file
            filepath = file.get_path()
            self.nbasmSRCScanned += 1
            #initialization
            self.lineNb = 0
            
            """
            Scan one Assembler Macro file
            """

            self.caller_object = None
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
                #log.info("self.file is " + str(self.file))
                asmzos_defn_obj_bookmark = Bookmark(self.file, 0, -1, (self.lastlineNb-1), -1)
                #log.info("asmzos_defn_obj_bookmark is-->" + str(asmzos_defn_obj_bookmark))
                
                self.asmzos_defn_obj = self.__create_object(self,obj_name, "ASM_MACRO", self.file,self.filepath, asmzos_defn_obj_bookmark)
                self.nbmacroCreated += 1
                
            crc = binascii.crc32(content.encode()) 
            self.asmzos_defn_obj.save_property('checksum.CodeOnlyChecksum', crc % 2147483648)
                 
            
        elif ext.lower() in self.extensions:
            self.filepath = file.get_path()
    
            #log.info("Parsing file %s..." % file)
            self.project = file.get_project()
            
            self.guid_data = Path(file.get_path()).name
    
            self.file = file
            filepath = file.get_path()
            self.nbasmSRCScanned += 1
            #initialization
            self.lineNb = 0
            
            """
            Scan one Assembler  program file
            """
    
            
            self.caller_object = None
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
                asmzos_defn_obj_bookmark = Bookmark(self.file, 0, -1, (self.lastlineNb-1), -1)
                firstcode_line = "'"
                
                line_nb = 0
                macro_linenum = 0
                uncommented_line = 0
                macro_regex = re.compile(self.macro_check)
                
                asm_regexes = [macro_regex]
                #log.info("macro_regex is " + str(macro_regex))           
                self.asmzos_defn_obj = None         
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
                                self.asmzos_defn_obj = self.__create_object(self,obj_name, "ASM_MACRO", self.file,self.filepath, asmzos_defn_obj_bookmark)
                                self.nbpgmCreated += 1
                        else:
                            if self.asmzos_defn_obj is None:
                                self.asmzos_defn_obj = self.__create_object(self,obj_name, "ASMZOSProgram", self.file,self.filepath, asmzos_defn_obj_bookmark)
                                self.nbpgmCreated += 1
                            
                
                #log.info(" obj_name object created is " + str(obj_name))
                self.caller_object = self.asmzos_defn_obj
             
            crc = binascii.crc32(content.encode()) 
            self.asmzos_defn_obj.save_property('checksum.CodeOnlyChecksum', crc % 2147483648)
                 
            self.caller_bookmark_new = None
            with open_source_file(file.get_path()) as srcfile:
                #log.info(" Processing file is " + str(srcfile))
                obj = None
    
                self.exec_sql_found = "N"
    
                for line in srcfile:
                    self.lineNb +=1
                    if self.lineNb > 1 and not line.startswith("END_PROGRAM") and not line.startswith("*"):
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
                                        self.caller_bookmark_new = Bookmark(self.file, self.lineNb , start_pos, self.lineNb, end_pos)
                                        if called_program_name not in self.asm_unknown_prog_main_list.keys():
                                            try:
                                                obj = self.__create_object(self,called_program_name, "CallTo_program", self.caller_object,self.filepath, self.caller_bookmark_new)
                                                self.asm_unknown_prog_main_list[called_program_name].append(obj)
                                            except:
                                                pass
                                        else:
                                            for key, val in self.asm_unknown_prog_main_list.items():
                                                if key == called_program_name:
                                                    link = ('callLink', self.caller_object, val, self.caller_bookmark_new)
                                                    self.links.append(link)

                                elif only_regex == self.exec_sql_call_regex:
                                    self.exec_sql_found = "Y"
                                    self.sql_query += line
                                    self.first_sql_lineNb = self.lineNb
                            
                            elif len(line) > 10:
                                if processed_line == "N":
                                    processed_line = "Y"
                                    if line[9] != " " and self.exec_sql_found == 'Y':
                                        #log.info("self.sql_query is " + str(self.sql_query))
                                        self.caller_object.save_property('CAST_SQL_MetricableQuery.sqlQuery', self.sql_query)
                                        self.db_caller_bookmark = Bookmark(self.file, self.first_sql_lineNb , 0, (self.lineNb-1), 0)
                                        self.link_to_db_object()
                                        self.sql_query = ""
                                        self.exec_sql_found = "N"
    
                                    else:
                                        if self.exec_sql_found == "Y":
                                            self.sql_query += line
                                
                            
                            
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
        log.info(" Statistics for AIA ")
        log.info("*****************************************************************")
        log.info(" Number of Source files Scanned " + str(self.nbasmSRCScanned))
        log.info(" Number of Links Created " + str(self.nbLinksCreated))
        log.info(" Total ASM Program Objects Created  -- > " + str(self.nbpgmCreated))
        log.info("*****************************************************************")

    def create_guid(self, objectType, objectName):
        
        if not type(objectName) is str:
            return objectType + '/' + objectName.name
        else:
            return objectType + '/' + objectName

    def link_to_db_object(self):   
        
        #log.info("self.query_name is " + str(self.query_name))
        #log.info("self.query_data is " + str(self.query_data))
        if self.sql_query != "":   
            for embedded in external_link.analyse_embedded(self.sql_query):
                for _type in embedded.types:
                    #log.info(_type + " Link created between " + str(self.caller_object.name) + " and " + str(embedded.callee))
                    #log.info("self.db_caller_bookmark is " + str(self.db_caller_bookmark))
                    create_link(_type, self.caller_object, embedded.callee,self.db_caller_bookmark)
                    #self.nbLinksBItoDBObjCreated += 1
                    

def open_source_file(path, encoding=None):
    """
    Equivalent of python open(path) that autotdetects encoding.
    
    handles long path, UNC paths
    
    :param encoding: specified encoding (optional) 
    
    :rtype: file 
    """
    from chardet.universaldetector import UniversalDetector
    
    # for long pathes : see https://stackoverflow.com/questions/29557760/long-paths-in-python-on-windows
    local_path = path
    
    
    #log.debug("sys.platform.startswith is " + str(sys.platform))

    if sys.platform.startswith('win32'):
        constant = '\\\\?\\'
        
        if not local_path.startswith(constant):
            local_path = local_path.replace('/', '\\')
            if local_path.startswith(r'\\'):
                local_path = r'\\?\UNC' + local_path[1:]
            elif os.path.isabs(local_path):
                local_path = constant + local_path
    
    #log.debug("encoding is " + str(encoding))

    if not encoding:
        detector = UniversalDetector()
        with open(local_path, 'rb') as f:
            count = 0
            for line in f:
                detector.feed(line)
                count += 1
                if detector.done or count > 100: 
                    break
        detector.close()
    
        encoding = detector.result['encoding']
        log.debug('File %s has %s as detected encoding' % (path, encoding))
        
    result = open(local_path, 'r', encoding=encoding, errors='replace')
    return result


