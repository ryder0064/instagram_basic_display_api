package com.ryderchen.plugins.instagram_basic_display_api.ui

import android.app.Activity
import androidx.appcompat.app.AlertDialog
import com.ryderchen.plugins.instagram_basic_display_api.R

class LoadingDialog(private val activity: Activity) {

    private val dialog: AlertDialog = AlertDialog.Builder(activity).apply {
        setView(activity.layoutInflater.inflate(R.layout.loading_dialog, null))
        setCancelable(false)
    }.create()

    fun startLoadingDialog() {
        dialog.show()
    }

    fun dismissLoadingDialog() {
        dialog.dismiss()
    }
}