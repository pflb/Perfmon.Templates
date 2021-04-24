# Application for automatic creations of data collector croups, performance counters from templates


### Instruction

1. Run the `import.ps1.bat` file as an administrator.
2. Enter the following parameters:
    - Duration - *total duration*.
    - Sample interval - *sampling interval*.
    - Template Path - *path to the folder with templates*.
3. Click the `Импорт` button to import groups of data collectors into Perfmon.
4. Click the `Старт` button to run groups.

If you need to stop groups of data collectors, click the `Стоп` button.

To remove groups of data collectors, click the `Удалить` button. You can re-import them by clicking the `Импорт` button.

Data collector groups logs and error reports are saved according to the template settings 
(By default, in `%systemdrive%\PerfLogs\Admin`).

###Creating data collector group template
Data collector groups are created on the basis of templates. Example of templates are in the `Templates` folder at the
root of the project.

Templates are *.xml files with a specific structure.

The key parameters are the following:
- Template *file must have a* UTF-8 *encoding without* BOM.
- Duration - *is programmatically, the template should be presented as* `<Duration>#####</Duration>`.
- DisplayName and Description - *displayed group name and description* 
- OutputLocation - *is the path to save groups of data collectors. The first part should match the value of the* RootPath
*parameter*.
- RootPath - *is the root path. It is recommended to use the value of* `%systemdrive%\PerfLogs\Admin`.
- SubdirectoryFormat and SubdirectoryFormatPattern - *are the format of the group folder name. The name of the final 
folder from* OutputLocation *must match this format. It is recommended to use the value of 3 and yyyyMMdd_HHmm, respectively*.
- UserAccount - *is a username*.
- PerformanceCounterDataCollector - *is the block responsible for the parameters of a particular data collector. There 
can be several such blocks if you need to use the same assembler with different parameters*.
   
   The following can be listed from the important fields of this block:
  - Name - *is the display name of the data collector in Perfmon*.
  - FIleName - *is the name of the collector log file on the hard disk. Specified without an extension* (*it is specified
    in* LogFileFormat).
  - SampleInterval - *is the sample interval. Is set programmatically, the template should be presented as* 
    `<SampleInterval\>#####\</SampleInterval\>`.
  - LogFileFormat - *is the format of the collector log file on your hard drive. Valid values: 0 - csv, 1 - tsv, 3 - blg
    (binary)*.
  - Counter - *is the name of the performance counter included in the data collector (e.g., \Memory% Committed Bytes in 
    Use). It is permissible to use the names of counters on English and on the native local of the system. There may be 
    several* Counter *fields for different counters (but it is not recommended to include a large number of counters in 
    the same collector to avoid performance problems)*.
  - DataManager - *is an optional block needed to create a data collector group plucking report*. Key fields:
      - Enable - *set the value to* `1` *to create report*.  
      - ReportFileName and RuleTargetFileName - *report file names*.
  
In the future (after importing templates), the value of data collector parameters can be changed in Perfmon.