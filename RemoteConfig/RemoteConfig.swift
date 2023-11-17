//
//  RemoteConfig.swift
//  housing
//
//  Created by Swarandeep Singh Sran on 30/08/22.
//  Copyright © 2022 Facebook. All rights reserved.
//

import Foundation
import Firebase

public protocol RemoteConfiguration {
//	func fetchConfig<T: Codable>(for key: String, completionHandler: @escaping (Result<T, Error>)->Void)
}

public final class DefaultRemoteConfiguration : RemoteConfiguration {
	private struct RemoteConfigModel {
		var key: String
		var filePath: String
		var model: Codable.Type
	}
	
	static var shared = DefaultRemoteConfiguration()
	
	public func fetchConfig<T: Codable>(for key: String, success: @escaping ((T)->Void), failure: ((Error)->Void)? = nil) {
		let value = RemoteConfig.remoteConfig().configValue(forKey: key)
		if T.self == String.self {
			if let stringValue = value.stringValue as? T {
				success(stringValue)
				return
			}
		}
		DispatchQueue.global(qos: .userInteractive).async {
			do {
				let filterConfig = try JSONDecoder().decode(T.self, from: value.dataValue)
				DispatchQueue.main.async {
					success(filterConfig)
				}
			} catch {
				DispatchQueue.main.async {
					print("error")
					failure?(error)
				}
			}
		}
	}
	
	public func fetchConfigSync<T: Codable>(for key: String, type: T.Type? = nil) -> T? {
		let value = RemoteConfig.remoteConfig().configValue(forKey: key)
		
		if type == String.self {
			return value.stringValue as? T
		}
		
		let filterConfig = try? JSONDecoder().decode(T.self, from: value.dataValue)
		try? JSONEncoder().encode(value.dataValue)
		return filterConfig
	}
	
	func fetchConfig() {
#if IOS_NATIVE
		RemoteConfig.remoteConfig().setDefaults(fromPlist: "remote_config_defaults_staging")
#else
		RemoteConfig.remoteConfig().setDefaults(fromPlist: "remote_config_defaults_production")
#endif

		RemoteConfig.remoteConfig().fetch(withExpirationDuration: 0) { [weak self] (status, error) in
			guard let self = self else { return }
			guard error == nil else {
				printDebug("Failed to fetch remote config with \(error!)")
				return
			}
			printDebug("Hooray! Retrieved values from the cloud!")
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .secondsSince1970
			RemoteConfig.remoteConfig().activate()
		}
	}
	
	func getAllKeysData(moduleName: String = "") -> [String: Any] {
		var values: [String: Any] = [:]
		let keys = RemoteConfig.remoteConfig().keys(withPrefix: nil)
		if moduleName.isEmpty {
			for key in keys {
				let value = RemoteConfig.remoteConfig().configValue(forKey: key)
				values[key] = ["value": value.stringValue]
			}
		} else {
			let moduleKeys = RemoteConfigMapper.getModuleMapping(moduleName: moduleName)
			for key in moduleKeys {
				let value = RemoteConfig.remoteConfig().configValue(forKey: key)
				values[key] = ["value": value.stringValue]
			}
		}
		return values
	}
	
	func getKeysData(_ keys: [String]) -> [String: String?] {
		var values: [String: String?] = [:]
		for key in keys {
			values[key] = RemoteConfig.remoteConfig().configValue(forKey: key).stringValue
		}
		return values
	}
}
