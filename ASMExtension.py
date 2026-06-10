import cast_upgrade_1_6_25
import cast.analysers.ua
from cast.analysers import log, CustomObject, create_link, Bookmark
from cast.application import open_source_file
import os, sys, traceback, re, binascii
import cast
from collections import OrderedDict, defaultdict
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
        self.ygcall_regex = '\s+YGCALL\s+\'([\w\_\#\@]+)+\''
        self.copy_regex = "\s+COPY\s+([\w\_\#\@]+)"
        self.loadep_regex = "\s+LOAD\s+EP\s+([\w\_\#\@]+)"
 
        self.NAME_CLASS = r"[\w#@.\-\£]+"
 
        self.YGCALL_RE = re.compile(
            r"""\bYGCALL\s+         
                (['"])              
                (?P<name>""" + self.NAME_CLASS + r""")   
                \1                 
            """,
            re.IGNORECASE | re.VERBOSE
        )
 
 
 
        self.NAME_CLASS = r"[\w#@.\-]+"
 
        # COPY
        self.COPY_RE = re.compile(
            r"\bCOPY\s+(?P<name>" + self.NAME_CLASS + r")\b",
            re.IGNORECASE
        )
 
        # LOAD EP
        self.LOADEP_RE = re.compile(
            r"\bLOAD\s+EP\s+\=(?P<name>" + self.NAME_CLASS + r")\b",
            re.IGNORECASE
        )
 
        # CALL
        self.CALL_RE = re.compile(
            r"\bCALL\s+(?P<name>" + self.NAME_CLASS + r")\b",
            re.IGNORECASE
        )
 
        # Token at start of operand
        self.TOKEN_AT_START = re.compile(
            r"^\s*(?P<name>" + self.NAME_CLASS + r")\b",
            re.IGNORECASE
        )
 
        # EXEC CICS LOAD PROGRAM('NAME') or "NAME"
        self.CICS_LOAD_PROGRAM_RE = re.compile(
            r"\bCICS\s+LOAD\s+PROGRAM\s*\(\s*'\"['\"]\s*\)",
            re.IGNORECASE
        )
 
 
        self.asm_regexes = [re.compile(p) for p in [self.program_call_regex]]
 
        self.macros = defaultdict(list)
 
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
 
 
    def first_72(self, line):
        # Expand tabs, strip newline, pad/truncate to exactly 72 chars
        line = line.expandtabs(8).rstrip("\r\n")
        return (line + " " * 72)[:72]
 
    def parse_fields(self, seg):
        # Fixed-format slices
        right = seg[9:]
 
        # Split once: first token is opcode, remainder is operand (raw)
        parts = right.split(None, 1)
        if not parts:
            return "", "",""
 
        #return opcode, operand_raw
 
        opcode_field = parts[0]
 
        #opcode_field = seg[9:15]    # cols 10–15
        #operand_raw  = seg[15:71]   # cols 16–71
        # Remainder becomes operand; limit to typical field width (16–71 → 56 chars)
        operand_raw = parts[1][:56].rstrip() if len(parts) > 1 else ""
 
        # Extract first token from opcode field, then upper
        op = opcode_field.strip()
        if op:
            op = op.split()[0]
        operand = operand_raw.rstrip()
        
        return (op.upper() if op else ""), operand, {
            "opcode_field_raw": opcode_field,
            "operand_field_raw": operand_raw
        }
 
 
    def normalize_opcode_and_operand(self, opcode, operand):
        """
        Normalize:
          - LOAD EP=... -> ('LOAD_EP', value)
          - LOAD EP ... -> ('LOAD_EP', value)
          - LOAD P=...  -> ('LOAD_P', value)
          - LOAD P ...  -> ('LOAD_P', value)
        Handles the split 'LOAD E' + leading 'P' in operand.
        """
        if opcode and opcode.upper() == "LOAD":
            opu = (operand or "")
            lead = opu.lstrip()
 
            def consume_token(token):
                tlen = len(token)
                if lead[:tlen].upper() == token and (len(lead) == tlen or lead[tlen] in " =:"):
                    rest = lead[tlen:]
                    rest = rest.lstrip()
                    if rest and rest[0] in ('=', ':'):
                        rest = rest[1:].lstrip()
                    return rest
                return None
 
            rest = consume_token("EP")
            if rest is not None:
                return "LOAD_EP", rest
 
            rest = consume_token("P")
            if rest is not None:
                return "LOAD_EP", rest
 
            if operand and operand.lstrip().startswith("P"):
                lead = operand.lstrip()
                rest = lead[1:].lstrip()
                if rest and rest[0] in ('=', ':'):
                    rest = rest[1:].lstrip()
                return "LOAD_EP", rest
 
        # Default: return as-is
        return opcode, operand
 
 
 
    @staticmethod
    def __create_object(self, name, typ, parent,filepath, bookmark=None):
        obj = None
 
        fullname = self.create_guid(typ, name) + '/' + filepath + '/'
        
        try:
            if name != "":
                obj = CustomObject()                    
                obj.set_name(name)
                obj.set_fullname(fullname)
                obj.set_type(typ)
                obj.set_parent(parent)
                obj.set_guid(fullname)
                
                obj.save()
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
            return  # no need to do anything

        filepath = file.get_path().lower()
        log.info('Scanning ' + filepath)

        _, ext = os.path.splitext(filepath)

        if ext.lower() in self.extensions1:
            filepath = file.get_path()
            self.project = file.get_project()
            self.nbasmSRCScanned += 1

            self.call_to_program_obj = None

            with open_source_file(filepath) as srcfile:
                content = srcfile.read()
                srcfile.seek(0)   
                mylist = [line.rstrip('\n') for line in srcfile]

            self.firstlineNb = 1
            self.lastlineNb = len(mylist)

            firstline = mylist[0]
            obj_name = firstline.split("(")[1].split(")")[0]

            self.start_pos = 1
            self.last_pos = 1

            asmzos_defn_obj_bookmark = Bookmark(file, 0, -1, self.lastlineNb - 1, -1)
            asmzos_defn_obj = self.__create_object(
                self, obj_name, "ASM_MACRO", file, filepath, asmzos_defn_obj_bookmark
            )
            self.macros[obj_name].append(asmzos_defn_obj)
            self.nbmacroCreated += 1

            crc = binascii.crc32(content.encode())
            asmzos_defn_obj.save_property('checksum.CodeOnlyChecksum', crc % 2147483648)
            
        elif ext.lower() in self.extensions:
            """
            Scan one Assembler program file
            """
            filepath = file.get_path()
            self.project = file.get_project()
            self.nbasmSRCScanned += 1

            # initialization
            self.call_to_program_obj = None
            asmzos_defn_obj = None

            with open_source_file(filepath) as srcfile:
                content = srcfile.read()
                srcfile.seek(0)   
                mylist = [line.rstrip('\n') for line in srcfile]

            self.firstlineNb = 1
            self.lastlineNb = len(mylist)

            firstline = mylist[0]
            obj_name = firstline.split("(")[1].split(")")[0]

            self.start_pos = 1
            self.last_pos = 1

            asmzos_defn_obj_bookmark = Bookmark(file, 0, -1, self.lastlineNb - 1, -1)

            macro_regex = re.compile(self.macro_check)
            asm_regexes = [macro_regex]

            # Decide whether to create Macro or Program object
            asmzos_defn_obj = None
            uncommented_line = 0
            for line_nb, line in enumerate(mylist, start=1):
                line = line[:72]
                if not line.startswith('*') and line_nb > 1:
                    uncommented_line += 1
                    matched = [regex for regex in asm_regexes if regex.match(line)]
                    if matched and uncommented_line == self.firstlineNb:
                        asmzos_defn_obj = self.__create_object(self, obj_name, "ASM_MACRO",
                                                               file, filepath, asmzos_defn_obj_bookmark)
                        self.macros[obj_name].append(asmzos_defn_obj)
                        self.nbpgmCreated += 1
                    elif asmzos_defn_obj is None:
                        asmzos_defn_obj = self.__create_object(self, obj_name, "ASMZOSProgram",
                                                               file, filepath, asmzos_defn_obj_bookmark)
                        self.programs.append((file, asmzos_defn_obj))
                        self.nbpgmCreated += 1

            caller_object = asmzos_defn_obj

            # Save checksum
            crc = binascii.crc32(content.encode())
            asmzos_defn_obj.save_property('checksum.CodeOnlyChecksum', crc % 2147483648)

            seen_end_exec = False
            line_number = 0
            self.caller_bookmark_new = None

            for line in mylist:
                line_number += 1
                line = self.first_72(line)

                if line_number > 1 and not line.startswith("END_PROGRAM") and not line.startswith("*"):
                    seg = line
                    out = {"YGCALL": None, "COPY": None, "LOAD_EP": None, "CALL": None, "CICS_PROGRAM": None}

                    opcode, operand, dbg = self.parse_fields(seg)
                    opcode, operand = self.normalize_opcode_and_operand(opcode, operand)

                    # Match opcodes
                    if opcode == "YGCALL":
                        m = self.YGCALL_RE.search(seg)
                        if m: out["YGCALL"] = {"name": m.group("name"), "span": m.span("name")}
                    elif opcode in ("COPY", "LOAD_EP", "CALL"):
                        m = self.TOKEN_AT_START.search(operand)
                        if m: out[opcode] = {"name": m.group("name"), "span": m.span("name")}
                    elif opcode == "EXEC":
                        m = self.CICS_LOAD_PROGRAM_RE.search(operand)
                        if m: out["CICS_PROGRAM"] = {"name": m.group("name"), "span": m.span("name")}

                    # Create bookmarks and links
                    for kind, info in out.items():
                        if info:
                            start_pos, end_pos = info["span"]
                            called_program_name = info["name"]
                            self.caller_bookmark_new = Bookmark(file, line_number, start_pos, line_number, end_pos)

                            if called_program_name not in self.asm_unknown_prog_main_list:
                                try:
                                    obj = self.__create_object(self, called_program_name, "CallTo_program",
                                                               caller_object, filepath, self.caller_bookmark_new)
                                    self.asm_unknown_prog_main_list.setdefault(called_program_name, []).append(obj)
                                except Exception as e:
                                    log.info("create_object failed: " + str(e))
                            else:
                                val = self.asm_unknown_prog_main_list.get(called_program_name, [])
                                link = ('callLink', caller_object, val, self.caller_bookmark_new)
                                self.links.append(link)

                if 'END-EXEC' in line:
                    seen_end_exec = True

            # Set variant
            asmzos_defn_obj.variant = Variant.with_end_exec if seen_end_exec else Variant.without_end_exec
                            
                            
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
                        line = line[:72]
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
