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



.ds.cfg.initialStateFunct:.fd[`initialStateFunct];

.dm.init[.fd.messagingServer`fullconfigname];


.log.out [.z.h;"Running initialStateFunct";()];
.trp.execute[(.ds.cfg.initialStateFunct`analyticname; `); {[err] .log.err[.z.h; "Error running initialStateFunct"; err]; 'err }];


