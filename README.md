Install Atlassian SourceTree Portable 
--------------------------------

Download and run [SourceTreePortable_0.0.1_Development_test_1.paf.exe](SourceTreePortable_0.0.1_Development_test_1.paf.exe?raw=true)

#####Getting Atlassian SourceTree

Download [SourceTreeSetup_1.6.12.exe](http://downloads.atlassian.com/software/sourcetree/windows/SourceTreeSetup_1.6.12.exe)

To extract files from SourceTreeSetup_1.6.12.exe file at the command line, type:

<pre>
SourceTreeSetup_1.6.12.exe /extract
msiexec /a SourceTreeSetup_1.6.12.msi /qb TARGETDIR="%temp%\SourceTree"
xcopy "%temp%\SourceTree" "drive\PortableApps\SourceTreePortable\App\SourceTree" /S
rmdir "%temp%\SourceTree" /S
</pre>
