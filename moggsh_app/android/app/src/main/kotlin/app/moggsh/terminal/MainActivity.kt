package app.moggsh.terminal

import android.content.Intent
import android.os.Build
import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channel = "app.moggsh.terminal/service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startForeground" -> {
                        val intent = Intent(this, TerminalForegroundService::class.java)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(null)
                    }
                    "stopForeground" -> {
                        stopService(Intent(this, TerminalForegroundService::class.java))
                        result.success(null)
                    }
                    "invalidateWebView" -> {
                        // Give the WebView Android view-focus so Chromium's renderer
                        // receives a focus signal and stops throttling frames.
                        // postInvalidate() alone only redraws the last compositor
                        // frame — it doesn't produce a new one from Chromium.
                        findWebViews(window.decorView).forEach { wv ->
                            wv.requestFocus()
                            wv.postInvalidate()
                        }
                        result.success(null)
                    }
                    "getNativeLibDir" -> result.success(applicationInfo.nativeLibraryDir)
                    else -> result.notImplemented()
                }
            }
    }

    private fun findWebViews(view: View): List<WebView> {
        if (view is WebView) return listOf(view)
        if (view !is ViewGroup) return emptyList()
        val result = mutableListOf<WebView>()
        for (i in 0 until view.childCount) result += findWebViews(view.getChildAt(i))
        return result
    }
}
