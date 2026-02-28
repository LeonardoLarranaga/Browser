//
//  WKWebsiteDataType.swift
//  Eva
//
//  Created by Leonardo Larrañaga on 27/2/26.
//

extension WKWebsiteDataRecord {
    var dataTypesDescriptions: [String] {
        Set(dataTypes.map {
            switch $0 {
            case WKWebsiteDataTypeFetchCache,
                WKWebsiteDataTypeDiskCache,
                WKWebsiteDataTypeMemoryCache,
                WKWebsiteDataTypeOfflineWebApplicationCache: "Cache"
            case WKWebsiteDataTypeCookies: "Cookies"
            case WKWebsiteDataTypeSessionStorage: "Session Storage"
            case WKWebsiteDataTypeLocalStorage: "Local Storage"
            case WKWebsiteDataTypeWebSQLDatabases,
                WKWebsiteDataTypeIndexedDBDatabases: "Databases"
            case WKWebsiteDataTypeServiceWorkerRegistrations: "Service Workers"
            case WKWebsiteDataTypeFileSystem: "File System"
            case WKWebsiteDataTypeSearchFieldRecentSearches: "Search Field Recent Searches"
            case WKWebsiteDataTypeMediaKeys: "Media Keys"
            case WKWebsiteDataTypeHashSalt: "Hash Salt"
            case WKWebsiteDataTypeScreenTime: "Screen Time"
            default: "Other"
            }
        }).sorted()
    }
}
