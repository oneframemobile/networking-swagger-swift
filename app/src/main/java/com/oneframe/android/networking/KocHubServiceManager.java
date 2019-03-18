//
//
//  Networking-Swagger Code Generate Creater 1.1
//  KocHubServiceManager.java
//  Copyright © 2019 OneFrame Mobile - Koçsistem All rights reserved.
//

package com.oneframe.android.networking;;

import com.oneframe.android.networking.NetworkConfig;
import com.oneframe.android.networking.NetworkManager;
import com.oneframe.android.networking.NetworkingFactory;
import com.oneframe.android.networking.listener.NetworkResponseListener;
import com.oneframe.android.networking.volleywrapper.GenericObjectRequest;
import com.oneframe.android.networking.model.ErrorModel;
import java.util.List;


//{{model_package}}

public class KocHubServiceManager {

    private static final String RESULT_TAG = "[JSON_KEY]";

    private NetworkManager manager;

    public KocHubServiceManager() {
        manager = NetworkingFactory
                .create()
                .setJsonKey(RESULT_TAG);
                //.setNetworkLearning(new AdvancedNetworkLearning());

        NetworkConfig.getInstance().deleteAllHeaders();
        NetworkConfig.getInstance().setURL("http://178.211.54.214:5000/");
        //NetworkConfig.getInstance().setBodyContentType("application/json; charset=utf-8");

        /*
        NetworkConfig
                .getInstance()
                .addHeader("Cache-Control", "no-cache")
                .addHeader("LanguageCode", "en")
                .addErrorCodes(500);
        */
    }

    //{{request_func}}
}