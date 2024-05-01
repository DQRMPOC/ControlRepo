// TEMPLATE_VARS_START
/****** Start of settings block
// This block must appear at the start of the file.
// Any changes made to the start of the file may be lost.
// pr_description=External Process Launcher. Provides the ability to start external applications from Delta Control including applications that include the Delta Control API.
// dc_host=
// dc_port=0
// dc_taskset=
// dc_algroups=
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
// pr_parameter=name=workingDirectory|isRequired=false|default=.|type=Symbol|desc=directory to cd to before running the command
// pr_parameter=name=command|isRequired=false|default=|type=Symbol|desc=command to run
// pr_parameter=name=parameterText|isRequired=false|default=|type=Symbol|desc=additional command line parameters
// pr_parameter=name=parameterConfig|isRequired=false|default=DS_LAUNCH_COMMANDLINE_PARAMS|type=Configuration Parameter (Entity)|desc=
// pr_parameter=name=blockOnCommand|isRequired=false|default=false|type=Boolean|desc=If false then & is added to the end of the command line
// pr_parameter=name=runInBackground|isRequired=false|default=true|type=Boolean|desc=If true then nohup is added to the start of the command
// pr_parameter=name=proxyConfig|isRequired=false|default=DS_LAUNCH_COMMANDLINE_PARAMS|type=Configuration Parameter (Entity)|desc=
/****** End of setting block
// TEMPLATE_VARS_END
// TEMPLATE_VARS_START
/****** Start of settings block
// This block must appear at the start of the file.
// Any changes made to the start of the file may be lost.
// pr_description=External Process Launcher. Provides the ability to start external applications from Delta Control including applications that include the Delta Control API.
// dc_host=
// dc_port=19999
// dc_taskset=
// dc_algroups=
// dc_additionalFiles=
// dc_slaves=
// dc_debug=
// dc_timeout=
// dc_qtype=
// dc_memlimit=
// pr_parameter=name=workingDirectory|isRequired=false|default=.|type=Symbol|desc=
// pr_parameter=name=command|isRequired=false|default=|type=Symbol|desc=
// pr_parameter=name=parameterText|isRequired=false|default=|type=Symbol|desc=
// pr_parameter=name=parameterConfig|isRequired=false|default=|type=Symbol|desc=
// pr_parameter=name=blockOnCommand|isRequired=false|default=false|type=Boolean|desc=
// pr_parameter=name=runInBackground|isRequired=false|default=false|type=Boolean|desc=
/****** End of setting block
\c 10000 10000
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

.log.out[.z.h;"in DS_LAUNCH - Delta Process Launcher";()];

instanceName:string .ex.getMyinstanceName[];
ipwd:first system"pwd";
clibdir:":../clib/";
ldlib:"export LD_LIBRARY_PATH=../clib:${LD_LIBRARY_PATH};"

// Get Process Parameters
workingdir:string .utils.checkForEnvVar .fd[`workingDirectory];
command:string .utils.checkForEnvVar .fd[`command];
parameterText:string .utils.checkForEnvVar .fd[`parameterText];
parameterConfig:.fd[`parameterConfig]`configname;
proxyConfig:.fd[`proxyConfig]`configname;
blockOnCommand:.fd[`blockOnCommand];
runInBackground:.fd[`runInBackground];

// Load Params from prcl, config and text field.
prclparams:" " sv .z.x;
configparams:"";
$[10h~type config:.fd[`parameterConfig]`value;
	.log.warn[.z.h;"in DS_LAUNCH - ",.fd[`parameterConfig]`value;()];
	[
		configparams:raze {"-",(string x)," ",(string .utils.checkForEnvVar string y[x])," "}[;configd] each key configd:.utils.kvp[config];
		if[not(10h~type configparams);configparams:""]			
	]];	
proxyparams:"";
$[10h~type config:.fd[`proxyConfig]`value;
	.log.warn[.z.h;"in DS_LAUNCH - ",.fd[`proxyConfig]`value;()];
	[
		proxyparams:raze {"-",(string x)," ",(string .utils.checkForEnvVar string y[x])," "}[;configd] each key configd:.utils.kvp[config];
		if[not(10h~type proxyparams);proxyparams:""]			
	]];		
textparams:parameterText;

// The Params below are added for the current version of the C API. This should be reviewed.
process: first  .pl.getParameters[]`process;
logfile: first  .pl.getParameters[]`logfile;
cid:     first  .pl.getParameters[]`cid;
prhost:  first  .pl.getParameters[]`prhost;
prport:  first  .pl.getParameters[]`prport;
processport: first .pl.getParameters[]`dc_port;

cparams:" --instance-name=",process;
if[not cid~`; cparams,:" --instance-id=",cid];
if[not null .ex.getTaskID[]; cparams,:" --task-id=",string .ex.getTaskID[]];
if[`dc_heartbeatFrequency in key`.fd; if[0<.fd`dc_heartbeatFrequency; cparams,:" --heartbeat-frequency=",string .fd`dc_heartbeatFrequency]];
if[not logfile~`; cparams,:" --logging-filename=",logfile];
if[not null processport;if[0<processport; cparams,:" --instance-port=",string processport]];
cparams,:" --deltacontrol-primary-host=",prhost," --deltacontrol-primary-port=",prport;

// END C API PARAMS
.log.out[.z.h;"in DS_LAUNCH - setting working directory";(workingdir)];
// Set Working Directory
if[11h~type key hsym `$workingdir;
    system"cd ",workingdir;
 ];
cpwd:first system"pwd";

.log.out[.z.h;"in DS_LAUNCH - setting launch behavior";("blockOnCommand";blockOnCommand;"runInBackground";runInBackground)];

amp:$[blockOnCommand;"";" &"];
nohup:$[runInBackground;"nohup";""];
bExitafterCall:(blockOnCommand|runInBackground);
.pl.setexitblockedoncompletion[not bExitafterCall];

trthClientParams:" -deltacontrolUsernamePassword trthClient:KX33P1atf0rm"," -dsReportGeneratorAPort ",string .utils.checkForEnvVar["ENV=ds_report_generator_a_PORT="];

toRun:" " sv raze each string each (ldlib;nohup;command;proxyparams;trthClientParams;prclparams;configparams;textparams;cparams;amp);

.log.out[.z.h;("in DS_LAUNCH - Running ",toRun," from directory ",cpwd);()]; 
@[system;toRun;{[x] .ex.err[.z.h;"in DS_LAUNCH - Launcher ended unexpectedly";x]}];
.log.out[.z.h;"in DS_LAUNCH - finished launching External Application";()];
