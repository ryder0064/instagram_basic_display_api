package com.ryderchen.plugins.instagram_basic_display_api

import androidx.annotation.NonNull
import com.ryderchen.plugins.instagram_basic_display_api.utils.getKoinInstance

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** InstagramBasicDisplayApiPlugin */
class InstagramBasicDisplayApiPlugin : FlutterPlugin, ActivityAware {

  private lateinit var methodCallHandler: MethodCallHandlerImpl
  private val instagramBasicDisplayApi: InstagramBasicDisplayApi = getKoinInstance()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodCallHandler = MethodCallHandlerImpl(instagramBasicDisplayApi)
    methodCallHandler.startListening(flutterPluginBinding.binaryMessenger)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodCallHandler.stopListening()
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    instagramBasicDisplayApi.setActivityPluginBinding(binding)
  }

  override fun onDetachedFromActivity() {
    instagramBasicDisplayApi.detachActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }
}
