package com.ryderchen.plugins.instagram_basic_display_api.data.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ryderchen.plugins.instagram_basic_display_api.data.DataRepository
import kotlinx.coroutines.launch

class AccessTokenViewModel(private val repository: DataRepository) : ViewModel() {
    val getAssessTokenResult: LiveData<Boolean?> = repository.accessTokenResult

    fun getAssessToken(
        clientId: String,
        clientSecret: String,
        code: String,
        redirectUri: String
    ) {
        println("getAssessToken")
        viewModelScope.launch {
            repository.getAccessToken(
                clientId,
                clientSecret,
                code,
                redirectUri
            )
        }
    }

    override fun onCleared() {
        super.onCleared()
        repository.clear()
    }
}