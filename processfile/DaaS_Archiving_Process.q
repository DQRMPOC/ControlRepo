// TEMPLATE_VARS_START
/****** Start of settings block
// This block must appear at the start of the file.
// Any changes made to the start of the file may be lost.
// pr_description=Directory threshold management and archiving process
// dc_host=10.185.130.148
// dc_port=3092
// dc_taskset=0
// dc_algroups=.daas.admin.diskM,daasEvents,daasUtil
// dc_additionalFiles=
// dc_slaves=
// dc_debug=
// dc_timeout=
// dc_qtype=
// dc_memlimit=
// dc_ispermissioned=
// dc_nosystem=
// dc_gmtoffset=
// dc_gc=
// dc_heartbeatFrequency=
// dc_heartbeatTimeout=
// pr_parameter=name=messagingServer|isRequired=true|default=DS_MESSAGING_SERVER|type=Configuration Parameter (Entity)|desc=Messaging Server
// pr_parameter=name=initialStateFunct|isRequired=true|default=.daas.admin.thresholdInit|type=Analytic|desc=Initialisation Function
/****** End of setting block
// TEMPLATE_VARS_END
{[]
    // list of chars so secret key cannot be seen using value
    (::;" ";"!";"\"";"#";"$";"%";"&";"'";"(";")";"*";"+";",";"-";".";"/";"0";"1";"2";"3";"4";"5";"6";"7";"8";"9";":";";";"<";"=";">";"?";"@";"[";"\\";"]";"^";"_";"`";"{";"|";"}";"~");
    tm:.z.Z;
    chk:.ex.prh(`.lic.check;`packages;"DeltaStream";tm);
    if[not first chk;
        .ex.err[.z.h;last chk;chk 1];
        exit 21;
    ];
    if[not 1b~.[{[x;y;z;s;c] last[c]~md5 string[x],y,string[z],s};(`packages;"DeltaStream";tm;"+"," ","-","&","?","&";chk);0b];
        .ex.err[.z.h;"license function .lic.check is not valid";()];
        exit 22;
    ];
 }[];

// DO NOT exit Process when finished loading
.pl.setexitblockedoncompletion[1];

// Parameters from GUI
.log.out [.z.h;"Loading input parameters";()];

.ds.cfg.host:.fd[`dc_host];
.log.out [.z.h;"Host is now defined. .ds.cfg.host";.ds.cfg.host];

.ds.cfg.portNo:.fd[`dc_port];
.log.out [.z.h;"Port number is now defined. .ds.cfg.portNo";.ds.cfg.portNo];

.ds.cfg.instanceName:first `$.fd[`process];
.log.out [.z.h;"Process name is now defined. .ds.cfg.instanceName";.ds.cfg.instanceName];

.ds.cfg.procName:.ex.getMyinstanceName[];
.log.out [.z.h;"Process instance name is now defined. .ds.cfg.procName";.ds.cfg.procName];

.ds.cfg.initialStateFunct:$[`initialStateFunct in key .fd;.fd[`initialStateFunct];.fd[`getInitialDataStateFunct]];
.log.out [.z.h;"Get initial data state fuction is now defined. .ds.cfg.initialStateFunct";.ds.cfg.initialStateFunct];

.ds.cfg.debug:.fd[`debug];

.ds.cfg.useDM:@[{not null first first value flip .fd.messagingServer`value};`;0b];

if[.ds.cfg.useDM;
	.dm.init[.fd.messagingServer`fullconfigname]];
  
.al.callfunction[`.daas.infra.procParams][];
	
//connect to event bus
.daas.cfg.eventResponsesByTopic:`topic xkey .uc.getActiveParamValue[`.daas.cfg.eventResponsesByTopic;`];
.al.callfunction[`.daas.events.startEventService][];

//ensure bashscripts are written down to disk
.al.callfunction[`.daas.admin.writeStringToBash][];
.log.out[.z.h;"Bash scripts written down from config";()];

//START ADMIN ARCHIVING PROCESSING
//load in allocations table
.uc.getAndSaveActiveParamValue[`.daas.admin.diskM.hdbAllocationTable;`;`.daas.admin.diskM.hdbAllocationTable;(`keyCols`action)!((`daasInstance`fileSystem`directoryName);())];
.log.out [.z.h;"Loaded in hdb allocation table";()];
.uc.getAndSaveActiveParamValue[`.daas.admin.diskM.fileAllocationTable;`;`.daas.admin.diskM.fileAllocationTable;(`keyCols`action)!((`daasInstance`fileSystem`directoryName);())];
.log.out [.z.h;"Loaded in file allocation table";()];

.log.out[.z.h;"got here";()];

// calculate diskspace allocation for one row or full table and upsert into table
if[not null first exec daasInstance from .daas.admin.diskM.hdbAllocationTable;.daas.admin.diskM.calculateDirAllocation ./: flip value exec daasInstance,fileSystem,directoryName,directorySSH,archiveDirectoryName,archiveSSH,allocation from .daas.admin.diskM.hdbAllocationTable;.log.out[.z.h;"Calculated size of hdb allocations";()]];
if[not null first exec daasInstance from .daas.admin.diskM.fileAllocationTable;.daas.admin.diskM.calculateFileAllocation ./: flip value exec daasInstance,fileSystem,directoryName,directorySSH,archiveDirectoryName,archiveSSH,allocation from .daas.admin.diskM.fileAllocationTable;.log.out[.z.h;"Calculated size of file allocations";()]];

.log.out[.z.h;"Running Initialisation Function";()];
   	@[{(.ds.cfg.initialStateFunct`function)[];.log.out[.z.h;"Process initialised";`]};`;{.log.out[.z.h;"Initialisation failed";`]}];
