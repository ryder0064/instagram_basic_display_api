package com.ryderchen.plugins.instagram_basic_display_api.data.model

import com.squareup.moshi.Json

data class UserInfoResponse (
    @Json(name = "id")
    val id: String,
    @Json(name = "username")
    val username: String,
    @Json(name = "account_type")
    val accountType: String
)