// TEMPLATE_VARS_START
/****** Start of settings block
// This block must appear at the start of the file.
// Any changes made to the start of the file may be lost.
// pr_description=admin hdb copy
// dc_host=No_host_set
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
// pr_parameter=name=messagingServer|isRequired=true|default=DS_MESSAGING_SERVER|type=Configuration Parameter (Entity)|desc=Delta Messaging Server
// pr_parameter=name=initialStateFunct|isRequired=true|default=dxEmptyFunctionNull|type=Analytic|desc=Specifies initial state tasks and sets call backs.
/****** End of setting block
// TEMPLATE_VARS_END
.ds.cfg.initialStateFunct:.fd[`initialStateFunct];

.log.out [.z.h;"Running initialStateFunct";()];
.trp.execute[(.ds.cfg.initialStateFunct`analyticname; `); {[err] .log.err[.z.h; "Error running initialStateFunct"; err]; 'err }];
