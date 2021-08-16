package com.ryderchen.plugins.instagram_basic_display_api.di

import com.ryderchen.plugins.instagram_basic_display_api.InstagramBasicDisplayApi
import com.ryderchen.plugins.instagram_basic_display_api.data.DataRepository
import com.ryderchen.plugins.instagram_basic_display_api.data.remote.ApiInstagramService
import com.ryderchen.plugins.instagram_basic_display_api.data.remote.GraphInstagramService
import com.ryderchen.plugins.instagram_basic_display_api.data.viewmodel.AccessTokenViewModel
import com.ryderchen.plugins.instagram_basic_display_api.utils.Constants
import com.squareup.moshi.Moshi
import com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterFactory
import org.koin.androidx.viewmodel.dsl.viewModel
import org.koin.core.qualifier.named
import org.koin.dsl.module
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory

val instagramBasicDisplayApiModule = module {
    single {
        InstagramBasicDisplayApi(get())
    }
}

// Module for networking elements
val remoteDataSourceModule = module {

    single {
        Moshi.Builder()
            .add(KotlinJsonAdapterFactory())
            .build()
    }

    single<Retrofit>(named("API_INSTAGRAM_URL")) {
        Retrofit.Builder()
            .addConverterFactory(MoshiConverterFactory.create(get()))
            .baseUrl(Constants.API_INSTAGRAM_URL)
            .build()
    }

    single<Retrofit>(named("GRAPH_INSTAGRAM_URL")) {
        Retrofit.Builder()
            .addConverterFactory(MoshiConverterFactory.create(get()))
            .baseUrl(Constants.GRAPH_INSTAGRAM_URL)
            .build()
    }

    single { get<Retrofit>(qualifier = named("GRAPH_INSTAGRAM_URL")).create(GraphInstagramService::class.java) }
    single { get<Retrofit>(qualifier = named("API_INSTAGRAM_URL")).create(ApiInstagramService::class.java) }
}

val accessTokenModule = module {

    single {
        DataRepository(
            get(),
            get(),
            get()
        )
    }

    viewModel { AccessTokenViewModel(get()) }
}