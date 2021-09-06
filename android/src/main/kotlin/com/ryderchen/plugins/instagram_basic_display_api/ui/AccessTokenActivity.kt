package com.ryderchen.plugins.instagram_basic_display_api.ui

import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Message
import android.util.Log
import android.webkit.WebChromeClient
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.Observer
import com.ryderchen.plugins.instagram_basic_display_api.R
import com.ryderchen.plugins.instagram_basic_display_api.data.viewmodel.AccessTokenViewModel
import com.ryderchen.plugins.instagram_basic_display_api.utils.Constants
import org.koin.androidx.viewmodel.ext.android.viewModel

class AccessTokenActivity : AppCompatActivity() {

    private lateinit var clientId: String
    private lateinit var clientSecret: String
    private lateinit var redirectUri: String

    private val viewModel: AccessTokenViewModel by viewModel()

    private val webView: WebView by lazy {
        findViewById<WebView>(R.id.webView)
    }
    private val loadingDialog: LoadingDialog by lazy {
        LoadingDialog(this)
    }
    private val TAG = javaClass.name
    private val webViewClient: WebViewClient = object : WebViewClient() {

        override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
            if (isAuthCodeExist(url)) {
                return false
            }
            return super.shouldOverrideUrlLoading(view, url)
        }

        @RequiresApi(Build.VERSION_CODES.N)
        override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                if (isAuthCodeExist(request.url.toString())) {
                    loadingDialog.startLoadingDialog()
                    getAccessToken(request.url.toString())
                    view.stopLoading()
                    return false
                }
                view.loadUrl(request.url.toString())
            }
            return false
        }
    }

    private inner class FlutterWebChromeClient : WebChromeClient() {
        override fun onCreateWindow(
            view: WebView, isDialog: Boolean, isUserGesture: Boolean, resultMsg: Message
        ): Boolean {
            val webViewClient: WebViewClient = object : WebViewClient() {
                @TargetApi(Build.VERSION_CODES.LOLLIPOP)
                override fun shouldOverrideUrlLoading(
                    view: WebView, request: WebResourceRequest
                ): Boolean {
                    if (isAuthCodeExist(request.url.toString())) {
                        return false
                    }
                    webView.loadUrl(request.url.toString())
                    return true
                }

                override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
                    if (isAuthCodeExist(url)) {
                        return false
                    }
                    webView.loadUrl(url)
                    return true
                }
            }
            val newWebView = WebView(webView.context)
            newWebView.webViewClient = webViewClient
            val transport = resultMsg.obj as WebView.WebViewTransport
            transport.webView = newWebView
            resultMsg.sendToTarget()
            return true
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_access_token)

        val intent = intent
        clientId = intent.getStringExtra(CLIENT_ID_EXTRA)!!
        clientSecret = intent.getStringExtra(CLIENT_SECRET_EXTRA)!!
        redirectUri = intent.getStringExtra(REDIRECT_URI_EXTRA)!!

        Log.d(
            "$TAG",
            "clientId = $clientId, clientSecret = $clientSecret, redirectUri = $redirectUri"
        )
        webView.loadUrl("https://www.instagram.com/oauth/authorize?client_id=$clientId&redirect_uri=$redirectUri&scope=user_profile,user_media&response_type=code")
        webView.settings.javaScriptEnabled = true

        // Open new urls inside the webview itself.
        webView.webViewClient = webViewClient

        // Multi windows is set with FlutterWebChromeClient by default to handle internal bug: b/159892679.
        webView.settings.setSupportMultipleWindows(true)
        webView.webChromeClient = FlutterWebChromeClient()

        viewModel.getAssessTokenResult.observe(this, Observer<Boolean?> { getAssessTokenResult ->
            Log.d(TAG, "getAssessTokenResult = $getAssessTokenResult")
            if(getAssessTokenResult == null) return@Observer
            loadingDialog.dismissLoadingDialog()
            if (getAssessTokenResult) {
                intent.putExtra(Constants.GET_ACCESS_TOKEN_RESULT, getAssessTokenResult)
                setResult(RESULT_OK, intent)
            } else {
                setResult(RESULT_CANCELED)
            }
            finish()
        }
//                Observer { getAssessTokenResult ->
//
//            Log.d(TAG, "getAssessTokenResult = $getAssessTokenResult")
//            loadingDialog.dismissLoadingDialog()
//            if (getAssessTokenResult) {
//                intent.putExtra(Constants.GET_ACCESS_TOKEN_RESULT, getAssessTokenResult)
//                setResult(RESULT_OK, intent)
//            } else {
//                setResult(RESULT_CANCELED)
//            }
//            finish()
//        }
        )
    }

    private fun isAuthCodeExist(url: String): Boolean {
        Log.d(TAG, "checkAuthCodeExist url = $url:")
        return url.startsWith(redirectUri)
    }

    private fun getAccessToken(url: String) {
        if (url.contains("code=")) {
            val startIndex = url.indexOf("code=", 0) + 5
            // #_ 是附加到重新導向 URI 的結尾，非代碼本身的一部分
            val endIndex = url.lastIndex - 1
            val code = url.substring(startIndex, endIndex)
            Log.d(TAG, "oauth authorize code = $code")
            viewModel.getAssessToken(
                clientId,
                clientSecret,
                code,
                redirectUri
            )
        } else {
            Log.d(TAG, "redirect url error = $url")
            setResult(RESULT_CANCELED)
            finish()
        }
    }

    companion object {
        private const val CLIENT_ID_EXTRA = "client_id"
        private const val CLIENT_SECRET_EXTRA = "client_secret"
        private const val REDIRECT_URI_EXTRA = "redirect_uri"

        fun createIntent(
            context: Context,
            clientId: String,
            clientSecret: String,
            redirectUri: String
        ): Intent {
            return Intent(context, AccessTokenActivity::class.java)
                .putExtra(CLIENT_ID_EXTRA, clientId)
                .putExtra(CLIENT_SECRET_EXTRA, clientSecret)
                .putExtra(REDIRECT_URI_EXTRA, redirectUri)
        }
    }
}