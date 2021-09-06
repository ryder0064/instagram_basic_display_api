package com.ryderchen.plugins.instagram_basic_display_api.data.model

import com.squareup.moshi.Json

data class MediasResponse (
    @Json(name = "data")
    val data: List<Map<String, Any>>
)