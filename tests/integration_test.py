import cast_upgrade_1_6_23
import unittest
import cast.analysers.test


def get_data_created_by_plugin(analysis):

    projects = analysis.get_objects_by_category('CAST_PluginProject').items()

    if not projects:
        return {},{}

    this_project = None

    for _, project in projects:
        
        if getattr(project, 'CAST_Scriptable.id') == 'com.castsoftware.uc.asmzos':
            this_project = project
            break

    
    objects_produced = set() 
    
    for _, link in analysis.get_objects_by_category('isInProjectLink').items():
        
        if getattr(link, 'link.callee') == this_project:
            
            _object = getattr(link,'link.caller')
            # skip project itself
            if getattr(_object,'type') != 'CAST_PluginProject':
                
                objects_produced.add(_object)
            
    links_produced = set()
    
    for _, link in analysis.get_objects_by_property('link.project', this_project, 'link').items():
        links_produced.add(link)
    
    print('objects')
    for o in objects_produced:
        
        print('  ', o.type, getattr(o,'identification.fullName'), getattr(o,'identification.name'))
        if hasattr(o,'CAST_Java_Service_DebugInformation.debug'):
            print('  ', '  ', getattr(o,'CAST_Java_Service_DebugInformation.debug'))
            
    
    print('links')
    for o in links_produced:
        
        caller = getattr(o, 'link.caller')
        callee = getattr(o, 'link.callee')
        
        print('  ', caller.type, getattr(caller,'identification.fullName'), '-', o.type, '->', callee.type, getattr(callee,'identification.fullName'))



class TestIntegration(unittest.TestCase):

    def test_create_program(self):

        analysis = cast.analysers.test.UATestAnalysis('Assembler')
        
        analysis.add_selection('sample')
#         analysis.set_verbose()
        analysis.run()

#         get_data_created_by_plugin(analysis)
        
        self.assertTrue(analysis.get_objects_by_name('GIMASAMP', 'ASMZOSProgram'))

    def test_macro_linking(self):

        analysis = cast.analysers.test.UATestAnalysis('Assembler')
        
        analysis.add_selection('macros/sample1')
#         analysis.set_verbose(True)
        analysis.run()

#         get_data_created_by_plugin(analysis)
        
        pgm = analysis.get_object_by_name('PGM', 'ASMZOSProgram')
        self.assertTrue(pgm)

        macro = analysis.get_object_by_name('MYMACRO', 'ASM_MACRO')
        self.assertTrue(macro)

        self.assertTrue(analysis.get_link_by_caller_callee('callLink', pgm, macro))

    def test_macro_linking_with_label(self):

        analysis = cast.analysers.test.UATestAnalysis('Assembler')
        
        analysis.add_selection('macros/sample2')
#         analysis.set_verbose(True)
        analysis.run()

#         get_data_created_by_plugin(analysis)
        
        pgm = analysis.get_object_by_name('PGM', 'ASMZOSProgram')
        self.assertTrue(pgm)

        macro = analysis.get_object_by_name('MYMACRO', 'ASM_MACRO')
        self.assertTrue(macro)

        self.assertTrue(analysis.get_link_by_caller_callee('callLink', pgm, macro))


if __name__ == "__main__":
    unittest.main()
