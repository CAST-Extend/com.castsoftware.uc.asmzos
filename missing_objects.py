import cast_upgrade_1_6_23 # @UnusedImport
from cast.application import ApplicationLevelExtension
from logging import info, debug
from cast import Event


class MissingSQLObjects(ApplicationLevelExtension):

    @Event('com.castsoftware.sqlanalyzer', 'create_missing_objects')
    def create_missing_objects(self, service):
        # test
        info(' Start create_missing_objects for Assembler  ... ')
        try:
            service.create_missing_objects('ASMZOSProject',
                                           'CAST_SQL_MetricableQuery',
                                           138293,
                                           'ASMZOS_MissingTable_Schema',
                                           'ASMZOS_MissingTable_Table',
                                           'ASMZOS_MissingTable_Procedure',
                                           'Assembler')
        except Exception as unexpected_py_exception:
            debug(' Internal exception with  create_missing_objects for Assembler (%s)... '
                  % unexpected_py_exception)

        info(' End create_missing_objects for Assembler ... ')



