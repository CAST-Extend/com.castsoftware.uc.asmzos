import cast_upgrade_1_6_23 # @UnusedImport
from cast.application import ApplicationLevelExtension, create_link
import logging
from builtins import len
import os, codecs, re
import zipfile
import time 
from os.path import dirname as up
from zipfile import ZIP_DEFLATED


class asmpreproc(ApplicationLevelExtension):

 
    def __init__(self):
        
        ApplicationLevelExtension.__init__(self)
        self.extensions = ['.asm','.mlc']
        self.extensions1 = ['.asmacro']

    def start_application(self, application):
         
        logging.info("Running code at the Start an application. Adding Tags to the file extensions ASM")
        aps_au_source_included_folder = []
        self.start_tag = 'BEGIN_PROGRAM('
        self.end_tag = 'END_PROGRAM'
        self.start_tag1 = 'BEGIN_MACRO('
        self.end_tag1 = 'END_MACRO'
        self.nbASMSourceFilesScanned = 0
        self.nbASMSourceFilesUpdated = 0
        self.nbASMacroFilesScanned = 0
        self.nbASMacroFilesUpdated = 0

        mngt_app = application.get_application_configuration()
        for analysis_unit in mngt_app.get_analysis_units():
            curr_au_folder = ""
            prev_au_folder = ""
            for au_techno in analysis_unit.ua_technologies:
                curr_au_folder = analysis_unit.get_included_selection()
                if au_techno in ['Assembler']:
                ## Retrieve the deploy path location and add the TAGS
                    if prev_au_folder == "" or curr_au_folder != prev_au_folder:
                        logging.info(" Processing folder --> " + str(curr_au_folder))
                        aps_au_source_included_folder.append(curr_au_folder)
                
                prev_au_folder =  curr_au_folder
        update_sources(self, aps_au_source_included_folder)
        
        logging.info(" Statistics for AIA ")
        logging.info("*****************************************************************")
        logging.info(" Number of Source files Scanned " + str(self.nbASMSourceFilesScanned))
        logging.info(" Number of Source files Updated " + str(self.nbASMSourceFilesUpdated))
        logging.info("*****************************************************************")


        
def zipdir(src, dst, zip_name):
    """
    Function creates zip archive from src in dst location. The name of archive is zip_name.
    :param src: Path to directory to be archived.
    :param dst: Path where archived dir will be stored.
    :param zip_name: The name of the archive.
    :return: None
    """
    ### destination directory
    os.chdir(dst)
    ### zipfile handler
    with zipfile.ZipFile(zip_name, 'w',ZIP_DEFLATED) as ziph:
    ### writing content of src directory to the archive
        for root, dirs, files in os.walk(src):
            for file in files:
                ziph.write(os.path.join(root, file), arcname=os.path.join(root.replace(src, ""), file))




def update_sources(self,aps_au_source_included_folder):
    aps_source_included_file_list = []

    for p in aps_au_source_included_folder:  
        #self.zip_file_location =  p[0]
                
        #two_up = up(self.zip_file_location)
            
        #current_path = os.path.basename(os.path.normpath(self.zip_file_location))
                
        #self.new_file_name = time.strftime(current_path  + "%Y%m%d_%H%M%S.zip")
                
        #zipdir(self.zip_file_location, two_up, self.new_file_name)
        #zipdir(self.zip_file_location, two_up, self.new_file_name)
          
        aps_source_included_file_list.append(list_folder(p[0]))
        
    source_dir_path_list_ref = []

    for i in aps_source_included_file_list:
        source_file_list = i[0]
        source_dir_path_list = i[1]
        for dirn in source_dir_path_list:
            dirn = dirn.replace("\\","\\")
            source_dir_path_list_ref.append(dir)
            
        for file in source_file_list:
            if not file.endswith(".tmp"):
                head, tail = os.path.split(file)
                file_name =  tail.split(".")[0]
                _, ext = os.path.splitext(file.lower())
                if ext in self.extensions:
                    self.nbASMSourceFilesScanned += 1
                    all_lines = read_file(file)
                    logging.info(" Processing Source File " + str(file))
                    if len(all_lines.splitlines()) > 0:
                        existing_first_line = all_lines.splitlines()[0]                
                        start_line = self.start_tag + file_name + ")" + os.linesep
                        end_line = os.linesep + self.end_tag 
                        if existing_first_line.startswith(self.start_tag):
                            logging.info("Skipping the file since it already contains the Tags " + str(file))
                            pass
                        else:
                            new_lines = start_line + all_lines + end_line
                            self.nbASMSourceFilesUpdated += 1
                            #backup_file(self, file, all_lines, ".tmp")
                            try:
                                os.remove(file)    
                            except OSError:
                                logging.info("Could not remove the file" + str(file))
                                
                            backup_file(self, file, new_lines, "")
                    else:
                        logging.info(" Empty file " + str(file))
                   
                elif ext in self.extensions1:
                    self.nbASMacroFilesScanned += 1
                    all_lines = read_file(file)
                    logging.info(" Processing Source File " + str(file))
                    if len(all_lines.splitlines()) > 0:
                        existing_first_line = all_lines.splitlines()[0]                
                        start_line = self.start_tag1 + file_name + ")" + os.linesep
                        end_line = os.linesep + self.end_tag1 
                        if existing_first_line.startswith(self.start_tag1):
                            logging.info("Skipping the file since it already contains the Tags " + str(file))
                            pass
                        else:
                            new_lines = start_line + all_lines + end_line
                            self.nbASMacroFilesUpdated += 1
                            #backup_file(self, file, all_lines, ".tmp")
                            try:
                                os.remove(file)    
                            except OSError:
                                logging.info("Could not remove the file" + str(file))
                                
                            backup_file(self, file, new_lines, "")
                    else:
                        logging.info(" Empty file " + str(file))
    return

def backup_file(self, file, source_data, new_file_extn):

    logging.info(" Updating Source File " + str(file))
    logging.debug(" Inside backup_file function  " + str(file))
    new_file = file + new_file_extn
    with codecs.open(new_file, 'w', encoding = 'utf-8') as fw:
        fw.write(source_data)
    
    return


def list_folder(infolder):
    
    listfile = []
    dirlist = []
    
    
    infolder = os.path.normpath(infolder)
    for dirpath, dirnames, filenames in os.walk(infolder):      
        for filename in filenames:
            listfile.append(os.path.join(dirpath, filename))

        dirlist.append(dirpath)
    return listfile, dirlist

def read_file(sourcefile): 
    source_file_lines = ""
    
    try:
        with open(sourcefile, 'r') as fobj: 
            source_file_lines = fobj.read()
    except Exception:
        logging.info(" Exception encountered while reading the file " + str(Exception))
        pass
    
    return source_file_lines 
    
