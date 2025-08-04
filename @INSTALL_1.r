
#############################################################################
#                                                                           #
#                        Tcl/Tk Installer version 1.0                       #
#                           So far Windows only                             #
#                                                                           #
#############################################################################
require(tcltk) || stop("tcltk support is absent")
require(compiler)|| stop("library compiler is absent")

# Setting up the installation details
AppName<-"Geochemical Data Toolkit"
AppID<-"GCDkit" # TO BE ALWAYS FIXED
AppVerName<-"Il padrino sono io"
AppVersion<-6.0
AppPublisher<-"Vojtech Janousek"
AppPublisherURL<-"http://www.gcdkit.org"
##################################################


# Determine the user library, if it exists
options(show.error.messages=FALSE)
user.lib<-Sys.getenv("R_LIBS_USER") # "" if not set

ee<-try(setwd(user.lib))
if(class(ee)!="try-error") DefaultDirName<-user.lib else DefaultDirName<-.Library
options(show.error.messages=TRUE) 

#DefaultDirName<-readRegistry(key="Software\\R-core\\R\\3.2.1",hive="HLM")$InstallPath # R installation directory
#.libPaths()                 # all library trees R knows about


# Getting the name of the temporary directory with installation files
temp.histfile <- tempfile("Rrawhist")
savehistory(temp.histfile )
rawhist <- readLines(temp.histfile)
ee<-rawhist[length(rawhist)]

ee<-gsub("source[(]\"","",ee)
ee<-gsub("\"[)]","",ee)
ee<-gsub("\\","/",ee,fixed=TRUE)
ee<-gsub("/{1,}","/",ee)

installDir<-dirname(ee)
unlink(temp.histfile)
setwd(installDir)

#######################################################################################
# OS INFO
PlatformOS<-.Platform$OS
PlatformGUI<-.Platform$GUI #"Rgui"
Rversion<-paste(R.version$platform,paste(getRversion(),collapse="."))

#######################################################################################
# Startup message
tit<-paste("Installing ","GCDkit",", version: ", AppVersion," (",AppVerName,")","\n",sep="")
cat(tit)
cat(Rversion,"\n")
if(.Platform$OS.type=="windows"){
        cat(win.version(),"\n")
    }else{
        cat(.Platform$OS.type,"\n")
}
flush.console()

#######################################################################################

# Read the DESCRIPTION file on Windows systems 
if(.Platform$OS.type=="windows"){
    descFileName<-paste(AppID,"/DESCRIPTION",sep="")
    zipFile<-grep(paste("^",AppID,"_[.0-9]{1,}zip",sep=""),list.files(),value=TRUE)
    unzip(zipFile,descFileName)
    descFile<-read.dcf(descFileName)
    file.remove(descFileName) 

    # I cannot delete the empty dir on Windows otherwise than:
    options(show.error.messages=FALSE)
    try(system(paste("rmdir ",installDir,"\\",AppID,sep=""),show.output.on.console = FALSE))
    options(show.error.messages=TRUE)
}else{
    zipFile<-grep(paste("^",AppID,"_[.0-9]{1,}.tar.gz",sep=""),list.files(),value=TRUE)
}

# Load the compiled core of the installer
loadcmp("COMPILED")
