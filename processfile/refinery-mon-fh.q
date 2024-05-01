// TEMPLATE_VARS_START
/****** Start of settings block
// This block must appear at the start of the file.
// Any changes made to the start of the file may be lost.
// pr_description=Refinery Monitoring FeedHandler
// dc_host=
// dc_port=
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
// pr_parameter=name=messagingServer|isRequired=true|default=DS_MESSAGING_SERVER|type=Configuration Parameter (Entity)|desc=Delta Messaging Server
// pr_parameter=name=publishChannel|isRequired=true|default=monitoring_fh_output|type=Symbol|desc=Publish channel for FH to TP
/****** End of setting block

// Refinery Monitoring FeedHandler
// Copyright (c) 2019 - 2020 Kx Systems Inc

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


/ The supported tables by the FeedHandler. Any other table will be ignored in '.mfh.upd'
.mfh.cfg.publishTables:`MonitoringMetrics`MonitoringProcesses`MonitoringState;

/ The inbound table that will have the metric transformers applied to it
.mfh.cfg.transformTable:`MonitoringState;

/ Default set of transformers that must be defined in the FeedHandler. This table seeds the primary transformer
/ config '.mfh.transformers'
/  @see .mfh.updateTransformers
.mfh.cfg.defaultTransformers:`metricName xkey flip `metricName`transformFunc`targetTable!"SSS"$\:();
.mfh.cfg.defaultTransformers[`system.cpu]:                 (`.mfh.t.systemCpu;         `SystemCpu);
.mfh.cfg.defaultTransformers[`system.mem]:                 (`.mfh.i.metDictToTable;    `SystemMem);
.mfh.cfg.defaultTransformers[`system.fs]:                  (`.mfh.t.systemFs;          `SystemFileSystem);
.mfh.cfg.defaultTransformers[`system.kernel]:              (`.mfh.t.genericSysMetric;  `SystemMetric);
.mfh.cfg.defaultTransformers[`system.timeSync]:            (`.mfh.t.genericSysMetric;  `SystemMetric);
.mfh.cfg.defaultTransformers[`system.sys]:                 (`.mfh.t.genericSysMetric;  `SystemMetric);
.mfh.cfg.defaultTransformers[`system.load]:                (`.mfh.t.genericSysMetric;  `SystemMetric);
.mfh.cfg.defaultTransformers[`system.process]:             (`.mfh.t.genericSysMetric;  `SystemMetric);
.mfh.cfg.defaultTransformers[`system.nic]:                 (`.mfh.t.systemNic;         `SystemNetInterface);
.mfh.cfg.defaultTransformers[`system.netproto]:            (`.mfh.t.systemNetProto;    `SystemNetProtocol);
.mfh.cfg.defaultTransformers[`process.cpu]:                (`.mfh.t.process;           `ProcessCpu);
.mfh.cfg.defaultTransformers[`process.mem]:                (`.mfh.t.process;           `ProcessMem);
.mfh.cfg.defaultTransformers[`process.process]:            (`.mfh.t.process;           `ProcessInfo);
.mfh.cfg.defaultTransformers[`process.ping]:               (`.mfh.i.metDictToTable;    `ProcessPing);
.mfh.cfg.defaultTransformers[`mem.kdbUsageBytes]:          (`.mfh.i.metDictToTable;    `ProcessMemKdb);
.mfh.cfg.defaultTransformers[`process.connectionOpen]:     (`.mfh.i.metDictToTable;    `ProcessConnection);
.mfh.cfg.defaultTransformers[`process.connectionClosed]:   (`.mfh.i.metDictToTable;    `ProcessConnection);
.mfh.cfg.defaultTransformers[`ipc.pendingHandleBytes]:     (`.mfh.t.genericProcMetric; `ProcessMetric);
.mfh.cfg.defaultTransformers[`process.queryTimeout]:       (`.mfh.t.genericProcMetric; `ProcessMetric);
.mfh.cfg.defaultTransformers[`process.exit]:               (`.mfh.t.genericProcMetric; `ProcessMetric);
.mfh.cfg.defaultTransformers[`process.userAuthFailure]:    (`.mfh.t.genericProcMetric; `ProcessMetric);
.mfh.cfg.defaultTransformers[`hdb.availableDates]:         (`.mfh.t.genericProcMetric; `ProcessMetric);
.mfh.cfg.defaultTransformers[`hdb.latestDateRowCounts]:    (`.mfh.t.genericProcMetric; `ProcessMetric);
.mfh.cfg.defaultTransformers[`pdb.rollover]:               (`.mfh.t.genericProcMetric; `ProcessMetric);
.mfh.cfg.defaultTransformers[`tp.updDayCount]:             (`.mfh.t.genericProcMetric; `ProcessMetric);
.mfh.cfg.defaultTransformers[`consumer.updDayCount]:       (`.mfh.t.genericProcMetric; `ProcessMetric);
.mfh.cfg.defaultTransformers[`rdb.eodFlush]:               (`.mfh.t.genericProcMetric; `ProcessMetric);
.mfh.cfg.defaultTransformers[`eb.primaryState]:            (`.mfh.t.genericProcMetric; `ProcessMetric);
.mfh.cfg.defaultTransformers[`failover.process]:           (`.mfh.t.genericProcMetric; `ProcessMetric);
.mfh.cfg.defaultTransformers[`failover.stack]:             (`.mfh.t.genericProcMetric; `ProcessMetric);
.mfh.cfg.defaultTransformers[`failover.routing]:           (`.mfh.t.genericProcMetric; `ProcessMetric);
.mfh.cfg.defaultTransformers[`qr.queryDispatch]:           (`.mfh.i.metDictToTable;    `QueryDispatch);
.mfh.cfg.defaultTransformers[`qr.queryResult]:             (`.mfh.i.metDictToTable;    `QueryResponse);
.mfh.cfg.defaultTransformers[`gw.queryStatus]:             (`.mfh.t.gwQuery;           `GwQueryStatus);


/ The metric transformer functions and target table to publish the transformed data to
/  @see .mfh.updateTransformers
/  @see .mfh.transform
.mfh.transformers:0#.mfh.cfg.defaultTransformers;

/ Built with '.mfh.updateTransformers' configuration to provide the number of metrics
/ per output table. Any table with only a single metric being published to it will have the 'metricName'
/ column removed
.mfh.metricsPerTable:()!();

/ Built with '.mfh.updateTransformers' to cache the target schemas to ensure that only the expected columns
/ in the schemas are published downstream
.mfh.schemas:()!();


.mfh.init:{
    .daas.cfg.monFhTransformers:.uc.getActiveParamValue[`.daas.cfg.monFhTransformers; `];
    .mfh.updateTransformers[];

    .uc.getAndSaveActiveParamValue[`.daas.cfg.monFhTransformers; `; `.daas.cfg.monFhTransformers; enlist[`action]!enlist (`.mfh.updateTransformers; `)];

    .pl.setexitblockedoncompletion 1;

    set[`.u.upd; .mfh.upd];

    .dm.init .fd.messagingServer`fullconfigname;
    .dm.regsrcc[.fd.publishChannel;] each .mfh.cfg.publishTables except .mfh.cfg.transformTable;
    .dm.regsrcc[.fd.publishChannel;] each key .mfh.metricsPerTable;

    .pl.return_noexit `procname`status`port!(.ex.getInstanceName[]; `running; system "p");
 };


/ The primary UPD function, processing data received from the Monitoring daemons
/ All metrics received with the table set in '.mfh.cfg.transformTable' will be transformed based
/ on the configuration in '.mfh.transformers'. Any metrics received with no transformer defined
/ will be ignored.
/  @see .mfh.cfg.publishTables
/  @see .mfh.cfg.transformTable
/  @see .mfh.transformers
/  @see .mfh.transform
/  @see .mfh.publish
.mfh.upd:{[t;d]
    if[not t in .mfh.cfg.publishTables;
        :(::);
    ];

    if[not t = .mfh.cfg.transformTable;
        :.mfh.publish[t; d];
    ];

    / Ignore any invalid metrics sent (generally sent during daemon start up)
    metrics:delete from d where null generatedTime;
    metrics:0!`metricName xgroup metrics;

    transformers:exec metricName!targetTable from .mfh.transformers;

    ignoreMetrics:distinct[metrics`metricName] except key transformers;

    if[0 < count ignoreMetrics;
        .log.debug[`refineryMonFh;;()] "Ignoring metrics with no transformer - ",", " sv string ignoreMetrics;
        metrics:delete from metrics where metricName in ignoreMetrics;
    ];

    transformed:metrics[`metricName]!.mfh.transform each metrics;

    publishTbls:transformers metrics`metricName;

    .mfh.publish ./: flip (publishTbls; value transformed);
 };

/ Transforms metrics for a specific metric name based on the configuration defined in '.mfh.transformers'
/  @param metrics (Table) The metrics to transform
/  @returns (Table) The metrics post-transformation
/  @throws TransformNotPossibleException If more than one metric name is present in the table
/  @see .mfh.transformers
/  @see .mfh.metricsPerTable
.mfh.transform:{[metrics]
    if[not .Q.qt metrics;
        metrics:flip metrics;
    ];

    if[not 1 = count distinct metrics`metricName;
        .log.error[`refineryMonFh;;()] "Unexpected metrics in transformer function. Cannot transform";
        '"TransformNotPossibleException";
    ];

    metName:first metrics`metricName;
    transformer:.mfh.transformers metName;
    
    transformResult:@[get transformer`transformFunc; metrics; { (`TRANSFORM_FAIL;x) }];

    if[`TRANSFORM_FAIL~first transformResult;
        .log.warn[`refineryMonFh;;()] "Failed to transform metrics [ Function: ",string[transformer`transformFunc]," ]. Error - ",last transformResult;
        :();
    ];

    / If there's only one metric going into the table, don't store the metric name
    if[1 = .mfh.metricsPerTable transformer`targetTable;
        transformResult:enlist[`metricName]_ transformResult;
    ];

    :transformResult;
 };

/ Publishes the transformed data downstream via the Delta Messaging service. If the table sent is empty,
/ no publish is performed
/  @see .mfh.schemas
/  @see .dm.pubdatac
/  @see .fd.publishChannel
.mfh.publish:{[t;d]
    if[0 = count d;
        :(::);
    ];

    / Ensure only matching columns are published downstream to prevent mismatches
    d:(cols[d] inter .mfh.schemas t)#d;

    .dm.pubdatac[.fd.publishChannel; t; d];
 };

/ Re-builds the primary transformer configuration '.mfh.transformers' from the default list and any additional
/ transformers defined in Delta Control
/  @see .mfh.cfg.defaultTransformers
/  @see .daas.cfg.monFhTransformers
/  @see .mfh.transformers
.mfh.updateTransformers:{
    dcTransformers:select by metricName from .daas.cfg.monFhTransformers;
    dcTransformers:delete from dcTransformers where null metricName;

    allTransformers:.mfh.cfg.defaultTransformers upsert dcTransformers;

    .log.out[`refineryMonFh;;()] "Updated transformers list [ Default: ",string[count .mfh.cfg.defaultTransformers]," ] [ Custom: ",string[count dcTransformers]," ]";

    .mfh.transformers:allTransformers;

    .mfh.metricsPerTable:exec targetTable!metricName from select count metricName by targetTable from .mfh.transformers;

    schemaTabs:key[.mfh.metricsPerTable] union .mfh.cfg.publishTables except .mfh.cfg.transformTable;
    .mfh.schemas:schemaTabs!.ex.prh({ @[;`colnames] each .tbl.getActiveTableinfo each x }; schemaTabs);
 };


/ 'Flips' the dictionary within the 'metric' column of the specified table into a new table with the dictionary
/ keys as columns in the output
.mfh.i.metDictToTable:{[mTbl]
    :(,').(enlist[`metric]_; @[;`metric])@\:mTbl;
 };

/ Ungroups the dictionaries in the 'metric' column and makes the dictionary keys the column 'metricKey'
/  @see .mfh.i.ungroup
.mfh.i.genericUngroup:{[mTbl]
    :.mfh.i.ungroup[`metricKey; mTbl];
 };

/ Ungroups the dictionaries in the 'metric' column of the specified table
/  @param keyColName (Symbol) The name of the new column that the dictionary keys will be inserted into
.mfh.i.ungroup:{[keyColName; mTbl]
    mTbl:![mTbl; (); 0b; enlist[keyColName]!enlist (key@/:; `metric)];
    mTbl:update metric:value@/:metric from mTbl;

    :ungroup mTbl;
 };

.mfh.i.genericDictFlatten:{[mTbl]
    :.mfh.i.dictFlatten[`metricKey; mTbl];
 };

/ 'Flattens' the dictionaries in the 'metric' column of the specified column by extracting the dictionary
/ keys and then 'flipping the result dictionaries
/  @param keyColName (Symbol) The name of the new column that the dictionary keys will be inserted into
/  @see .mfh.i.ungroup
/  @see .mfh.i.metDictToTable
.mfh.i.dictFlatten:{[keyColName; mTbl]
    :.mfh.i.metDictToTable .mfh.i.ungroup[keyColName; mTbl];
 };


// .mfh.t: Custom metric transformers for specific metric types

.mfh.t.systemCpu:.mfh.i.dictFlatten[`cpu;];

.mfh.t.systemFs:.mfh.i.dictFlatten[`filesystem;];

.mfh.t.systemNic:.mfh.i.dictFlatten[`interface;];

.mfh.t.systemNetProto:{[mTbl]
    :.mfh.i.ungroup[`protocolStat;] .mfh.i.ungroup[`protocol; mTbl];
 };

/ All metrics are enlisted for 'anymap' support
.mfh.t.genericSysMetric:{[mTbl]
    :update metric:enlist each metric from .mfh.i.genericUngroup mTbl;
 };


.mfh.t.process:.mfh.i.dictFlatten[`pid;];

.mfh.t.gwQuery:{[mTbl]
    :.mfh.i.metDictToTable enlist[`details]_ update metric:details from .mfh.i.metDictToTable mTbl;
 };

/ All metrics are enlisted for 'anymap' support
.mfh.t.genericProcMetric:{[mTbl]
    :update metric:enlist each metric from .mfh.i.genericUngroup mTbl;
 };


.mfh.init[];
