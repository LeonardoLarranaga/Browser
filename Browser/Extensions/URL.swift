//
//  URL.swift
//  Browser
//
//  Created by Leonardo Larrañaga on 2/2/25.
//

import Foundation
import UniformTypeIdentifiers

extension URL {
    /// Returns the host of a URL
    /// - Example: `https://www.apple.com` returns `apple.com`
    var cleanHost: String {
        guard let host = self.host() else { return self.absoluteString }
        if host.contains("www") {
            return host.components(separatedBy: ".").dropFirst().joined(separator: ".")
        } else {
            return host
        }
    }
    
    func uniqueFileURL() -> URL {
        let fileManager = FileManager.default
        var url = self
        var count = 1
        
        let directory = deletingLastPathComponent()
        let filename = deletingPathExtension().lastPathComponent
        let fileExtension = pathExtension.isEmpty ? "" : ".\(pathExtension)"
        
        while fileManager.fileExists(atPath: path) {
            let newFilename = "\(filename) (\(count))\(fileExtension)"
            url = directory.appendingPathComponent(newFilename)
            count += 1
        }
        
        return url
    }
    
    /// Returns whether the URL is a directory
    var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
    
    /// The URL's file types
    var fileType: UTType? {
        UTType(filenameExtension: pathExtension)
    }
    
    func contains(_ type: UTType) -> Bool {
        UTType(mimeType: UTType(filenameExtension: self.pathExtension)?.preferredMIMEType ?? "application/octet-stream")?.conforms(to: type) ?? false
    }
    
    var route: String {
        let components = self.absoluteString.components(separatedBy: "/")
        guard components.count > 3 else { return "" }
        return components.dropFirst(3).joined(separator: "/")
    }
}

extension String {
    /// Detects if a string is a valid URL using a regular expression
    var isValidURL: Bool {
        do {
            let pattern = #"^((https?:\/\/)?(([\w-]+(?:\.[\w-]+)+)(:\d{1,5})?|([\w-]+:\d{1,5}))(\/\S*)?)$"#
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let results = regex.matches(in: self, range: NSRange(location: 0, length: self.utf16.count))
            return !results.isEmpty
        } catch {
            return false
        }
    }

    /// Returns whether this host is the same as or a subdomain of the supplied domain.
    func matchesWebsiteDomain(_ domain: String) -> Bool {
        let host = trimmingCharacters(in: CharacterSet(charactersIn: ".")).lowercased()
        let normalizedDomain = domain.trimmingCharacters(in: CharacterSet(charactersIn: ".")).lowercased()

        guard !host.isEmpty, !normalizedDomain.isEmpty else { return false }
        return host == normalizedDomain || host.hasSuffix(".\(normalizedDomain)")
    }
    
    var startsWithHTTP: Bool {
        hasPrefix("http://") || hasPrefix("https://")
    }
}
