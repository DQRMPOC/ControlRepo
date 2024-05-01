.qr.client.register[.ex.getInstanceName[]; 0Ni]:

.daas.qrClient.sendToQr:{[func; args] :.qr.client.sendSyncRequest[(func; args); `; ()!(); ::]; };

.daas.qrClient.init:{
    funcsToInstall:.al.getanalyticsbygroup `daasQR;
    { set[x;] .daas.qrClient.sendToQr[x;] } each funcsToInstall;
    };
    
.daas.qrClient.init[]
