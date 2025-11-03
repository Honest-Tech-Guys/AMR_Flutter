package com.example.rms_tenant_app; // Use your actual package name

import io.flutter.embedding.android.FlutterActivity;

// 1. ADD THIS IMPORT from the README
import com.ttlock.ttlock_flutter.TtlockFlutterPlugin;

public class MainActivity extends FlutterActivity {
    
    // 2. ADD THIS ENTIRE METHOD from the README
    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        TtlockFlutterPlugin ttlockflutterpluginPlugin = (TtlockFlutterPlugin) getFlutterEngine().getPlugins().get(TtlockFlutterPlugin.class);
        if (ttlockflutterpluginPlugin != null) {
            ttlockflutterpluginPlugin.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }
}
