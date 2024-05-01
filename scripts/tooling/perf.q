/ Global message counter
.perf.N:0;
/ Global results table
.perf.results:();
/ flush to disk after receiving over 999 messages
.perf.flushThresold:999;
/ Save location for flushed data
.perf.savePath:`:prof/;

.z.exit:.perf.write:{.perf.savePath upsert .perf.results};

.z.ts:{[]
    @[.perf.upd;::;{exit 0}]
    };

// Formatter for the name 
.perf.nm:{[n;f;l;c;t] 
    -20 sublist $[""~n;$[""~f;t;f,":",string[l],":",string[c]];n]
    };

// Timer function to pull stack timings from remote process
.perf.upd:{[]
    / Append to the in-mem results table
    `.perf.results upsert enlist flip update name:.perf.nm'[name;file;line;col;text] from select from .Q.prf0 .perf.pid where not .Q.fqk each file;
    
    / Flush samples if threshold breaches
    if[.perf.flushThresold<n:count .perf.results;
        .perf.N+:n;
        .perf.write[];
        delete from `.perf.results;
        1"\r",string["v"$.z.p-.perf.startTime]," ",string[.perf.N]," samples"
        ];

    };

// Main function to start profiling
// @param pid {int} PID of the process to profile
.perf.start:{[pid]
    if[-6h<>type pid;
        '`$"pid must be of type int"
        ];

    .perf.pid:pid;
    .perf.startTime:.z.p;
    system"t 10"
    };

// Stop profiling by turning of the timer
.perf.stop:{[]
    system"t 0"
    };

// Convert splayed table into format usable in speedscope.app
// @param output {hsym} Save location for the converted file
.perf.conv:{[output]
    output 0:(exec";"sv'ssr[;"[ ;]";"_"]each'name from .perf.savePath),\:" 1"
    };
